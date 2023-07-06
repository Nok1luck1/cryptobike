//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "./interface/IERC4907.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

contract Character is
    ERC721Upgradeable,
    ERC721EnumerableUpgradeable,
    ERC721BurnableUpgradeable,
    UUPSUpgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    IERC4907
{
    using StringsUpgradeable for uint256;
    using Counters for Counters.Counter;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    Counters.Counter public _globalCounter;

    address public OLDnft;
    address private signer;
    string public baseURI;
    struct UserInfo {
        address user;
        uint256 expires;
    }
    struct HashSig {
        bytes32 msgHash;
        bytes signature;
    }
    mapping(uint256 => UserInfo) internal _users;
    mapping(uint256 => string) private _tokenURIs;
    mapping(bytes32 => bool) private hashes;
    event SwapedOldForNew(address user, uint256 oldTokenID, uint256 tokenIdNEW);
    event Minted(
        uint256 _bikeType,
        uint256 _tokenId,
        address _to,
        address payableT,
        uint price
    );

    function initialize(
        string calldata name_,
        string calldata symbol_,
        string memory _baseURII
    ) public initializer {
        __ERC721_init(name_, symbol_);
        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        __ERC721Enumerable_init();
        __UUPSUpgradeable_init();
        __ERC721Enumerable_init();
        __Pausable_init();
        baseURI = _baseURII;
        signer = 0x5C5193544Fce3f8407668D451b20990303cc692a;
    }

    receive() external payable {}

    fallback() external payable {}

    function userOf(uint256 tokenId) public view virtual returns (address) {
        if (uint256(_users[tokenId].expires) >= block.timestamp) {
            return _users[tokenId].user;
        } else {
            return address(0);
        }
    }

    function userExpires(
        uint256 tokenId
    ) public view virtual returns (uint256) {
        return _users[tokenId].expires;
    }

    function tokenURI(
        uint tokenID
    ) public view override returns (string memory) {
        return _tokenURIs[tokenID];
    }

    function remasterNFT(uint256 tokenId, uint256 newTokenID) public {
        require(
            IERC721Upgradeable(OLDnft).balanceOf(_msgSender()) > 1,
            "old nft is missing"
        );
        require(tokenByIndex(newTokenID) == 0, "Already created");
        IERC721Upgradeable(OLDnft).safeTransferFrom(
            _msgSender(),
            0x0000000000000000000000000000000000000001,
            tokenId
        );
        mint(_msgSender(), newTokenID);
        emit SwapedOldForNew(_msgSender(), tokenId, newTokenID);
    }

    function setUser(
        uint256 tokenId,
        address user,
        uint64 expires
    ) public virtual {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC4907: transfer caller is not owner nor approved"
        );
        UserInfo storage info = _users[tokenId];
        info.user = user;
        info.expires = expires;
        emit UpdateUser(tokenId, user, expires);
    }

    function setBaseURI(
        string memory newBaseURI
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        baseURI = newBaseURI;
    }

    function changeSigner(
        address newSigner
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        signer = newSigner;
    }

    function isValidSig(
        HashSig memory hashSig
    ) public view returns (bool isValid) {
        address _signer = ECDSA.recover(hashSig.msgHash, hashSig.signature);
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
        mintAdmin(to, bikeType, payableT, price);
    }

    function mint(
        address to,
        uint256 id
    ) public onlyRole(DEFAULT_ADMIN_ROLE) returns (uint) {
        _globalCounter.increment();
        uint256 newItemId = _globalCounter.current();
        string memory link = string(
            bytes.concat(bytes(baseURI), bytes(StringsUpgradeable.toString(id)))
        );
        _mint(to, _globalCounter.current());
        _tokenURIs[_globalCounter.current()] = link;
        emit Minted(id, newItemId, to, address(0), 0);
        return _globalCounter.current();
    }

    function mintAdmin(
        address to,
        uint256 id,
        address tokenPay,
        uint price
    ) internal returns (uint) {
        _globalCounter.increment();
        uint256 newItemId = _globalCounter.current();
        string memory link = string(
            bytes.concat(bytes(baseURI), bytes(StringsUpgradeable.toString(id)))
        );
        _mint(to, _globalCounter.current());
        _tokenURIs[_globalCounter.current()] = link;
        emit Minted(id, newItemId, to, tokenPay, price);
        return _globalCounter.current();
    }

    function setPause(
        bool _newPauseState
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _newPauseState ? _pause() : _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    )
        internal
        virtual
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
        if (from != to && _users[tokenId].user != address(0)) {
            delete _users[tokenId];
            emit UpdateUser(tokenId, address(0), 0);
        }
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(
            ERC721Upgradeable,
            ERC721EnumerableUpgradeable,
            AccessControlUpgradeable
        )
        returns (bool)
    {
        return
            interfaceId == type(IERC4907).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}
}
