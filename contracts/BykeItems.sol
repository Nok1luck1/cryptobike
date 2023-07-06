//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract BykeItems is
    ERC1155Upgradeable,
    UUPSUpgradeable,
    ERC1155URIStorageUpgradeable,
    AccessControlUpgradeable,
    ERC1155BurnableUpgradeable
{
    using StringsUpgradeable for uint256;
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    CountersUpgradeable.Counter public _globalCounter;

    struct HashSig {
        bytes32 msgHash;
        bytes signature;
    }
    bytes32 public constant SIGNATURE_CHECKER = keccak256("SIGNATURE_CHECKER");
    address private signer;

    mapping(bytes32 => bool) private hashes;
    event Minted(
        uint256 _bikeType,
        uint256 _tokenId,
        address _to,
        address payableT,
        uint price
    );

    function initialize(string memory _baseURII) public initializer {
        __ERC1155_init(_baseURII);
        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        __UUPSUpgradeable_init();

        signer = 0x5C5193544Fce3f8407668D451b20990303cc692a;
        grantRole(
            DEFAULT_ADMIN_ROLE,
            0x5C5193544Fce3f8407668D451b20990303cc692a
        );
    }

    receive() external payable {}

    fallback() external payable {}

    function changeSigner(
        address newSigner
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        signer = newSigner;
    }

    function isValidSig(
        HashSig memory hashSig
    ) public view returns (bool isValid) {
        address _signer = ECDSAUpgradeable.recover(
            hashSig.msgHash,
            hashSig.signature
        );
        return !hashes[hashSig.msgHash] && _signer == signer;
    }

    function getMessageHashBuy(
        address to,
        address payableT,
        uint _bikeType,
        uint price,
        uint expiry
    ) public pure returns (bytes32) {
        return
            keccak256(abi.encodePacked(to, payableT, _bikeType, price, expiry));
    }

    function getEthSignedMessageHash(
        bytes32 _messageHash
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _messageHash
                )
            );
    }

    function buyNewNFT(
        address to,
        address payableT,
        uint bikeType,
        uint price,
        uint expiry,
        bytes memory sig
    ) public payable {
        bytes32 msgHash = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                keccak256(
                    abi.encodePacked(to, payableT, bikeType, price, expiry)
                )
            )
        );
        require(isValidSig(HashSig(msgHash, sig)), "Invalid signature");
        require(expiry > block.timestamp, "Expired");
        hashes[msgHash] = true;
        if (payableT == address(0)) {
            require(msg.value == price, "price mismatch");
            AddressUpgradeable.sendValue(payable(address(this)), price);
        } else {
            uint balanceB = IERC20Upgradeable(payableT).balanceOf(
                address(this)
            );
            IERC20Upgradeable(payableT).safeTransferFrom(
                msg.sender,
                address(this),
                price
            );
            uint balanceA = IERC20Upgradeable(payableT).balanceOf(
                address(this)
            );
            require(balanceA > balanceB, "Token dont transfered");
        }
        mintNew(to, bikeType, 1, payableT, price, "");
    }

    function mintAdmin(uint256 _bikeType, uint256 amount, address to) public {
        require(
            hasRole(SIGNATURE_CHECKER, _msgSender()) ||
                hasRole(DEFAULT_ADMIN_ROLE, _msgSender())
        );
        mintNew(to, _bikeType, amount, address(0), 0, "");
    }

    function mintNew(
        address to,
        uint _bikeType,
        uint amount,
        address payableT,
        uint price,
        bytes memory data
    ) internal {
        _globalCounter.increment();
        uint256 newItemId = _globalCounter.current();
        _setURI(
            _globalCounter.current(),
            StringsUpgradeable.toString(_bikeType)
        );
        _mint(to, newItemId, amount, data);
        emit Minted(_bikeType, newItemId, to, payableT, price);
    }

    function uri(
        uint256 tokenID
    )
        public
        view
        virtual
        override(ERC1155URIStorageUpgradeable, ERC1155Upgradeable)
        returns (string memory)
    {
        return ERC1155URIStorageUpgradeable.uri(tokenID);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC1155Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function setURI(
        uint256 id,
        string memory urL
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setURI(id, urL);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}
}
