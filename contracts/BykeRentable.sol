//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./interface/IERC4907.sol";

contract BykeRentable is
    ERC721Upgradeable,
    ERC721EnumerableUpgradeable,
    ERC721BurnableUpgradeable,
    UUPSUpgradeable,
    AccessControlUpgradeable,
    IERC4907
{
    using StringsUpgradeable for uint256;
    using Counters for Counters.Counter;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    Counters.Counter public _globalCounter;

    address private signer;
    string public baseURI;

    bytes32 public constant FACTORY_ROLE = keccak256("FACTORY_ROLE");
    bytes32 public constant SIGNATURE_CHECKER = keccak256("SIGNATURE_CHECKER");

    struct UserInfo {
        address user;
        uint256 expires;
    }
    struct HashSig {
        bytes32 msgHash;
        bytes signature;
    }
    mapping(uint256 => UserInfo) internal _users;
    mapping(bytes32 => bool) private hashes;
    mapping(uint256 => string) private _tokenURIs;

    event SignerChanged(address oldSigner, address newSigner);
    event Minted(
        uint256 _bikeType,
        uint256 _tokenId,
        address _to,
        address payableT,
        uint price
    );

    receive() external payable {}

    fallback() external payable {}

    function changeSigner(
        address newSigner
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        emit SignerChanged(signer, newSigner);
        signer = newSigner;
    }

    function initialize(
        address _signer,
        string calldata name_,
        string calldata symbol_,
        string memory _baseURII
    ) public initializer {
        __ERC721_init(name_, symbol_);
        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        __ERC721Enumerable_init();
        __UUPSUpgradeable_init();
        __ERC721Enumerable_init();
        baseURI = _baseURII;
        signer = _signer;
    }

    function tokenURI(
        uint tokenID
    ) public view override returns (string memory) {
        return _tokenURIs[tokenID];
    }

    function isValidSig(
        HashSig memory hashSig
    ) public view returns (bool isValid) {
        address _signer = ECDSA.recover(hashSig.msgHash, hashSig.signature);
        return !hashes[hashSig.msgHash] && _signer == signer;
    }

    function getMessageHash(
        address account,
        uint burnID,
        uint mintID,
        uint expiry
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(account, burnID, mintID, expiry));
    }

    function getMessageHash1(
        address account,
        address receiver,
        uint mintID,
        uint expiry
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(account, receiver, mintID, expiry));
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

    function burnAndMint(
        address account,
        uint burnID,
        uint mintID,
        uint expiry,
        bytes memory sig
    ) public {
        bytes32 msgHash = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                keccak256(abi.encodePacked(account, burnID, mintID, expiry))
            )
        );
        require(isValidSig(HashSig(msgHash, sig)), "Invalid signature");
        require(account == msg.sender, "Invalid account");
        require(expiry > block.timestamp, "Expired");
        hashes[msgHash] = true;
        burn(burnID);
        _mintInter(msg.sender, mintID, address(0), 0);
    }

    function mintFor(
        address account,
        address receiver,
        uint mintID,
        uint expiry,
        bytes memory sig
    ) public {
        bytes32 msgHash = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                keccak256(abi.encodePacked(account, receiver, mintID, expiry))
            )
        );
        require(isValidSig(HashSig(msgHash, sig)), "Invalid signature");
        require(account == msg.sender, "Invalid account");
        require(expiry > block.timestamp, "Expired");
        hashes[msgHash] = true;
        mint(receiver, mintID);
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
        _mintInter(to, bikeType, payableT, price);
    }

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

    function mint(address to, uint id) public returns (uint) {
        require(
            hasRole(SIGNATURE_CHECKER, _msgSender()) ||
                hasRole(DEFAULT_ADMIN_ROLE, _msgSender())
        );
        return _mintInter(to, id, address(0), 0);
    }

    function _mintInter(
        address to,
        uint256 id,
        address payableT,
        uint price
    ) internal returns (uint) {
        _globalCounter.increment();
        uint256 newItemId = _globalCounter.current();
        string memory link = string(
            bytes.concat(bytes(baseURI), bytes(Strings.toString(id)))
        );
        _mint(to, _globalCounter.current());
        _tokenURIs[_globalCounter.current()] = link;
        emit Minted(id, newItemId, to, payableT, price);
        return _globalCounter.current();
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

    function withdrawFee(
        address _token,
        uint256 _amount
    ) public onlyRole(DEFAULT_ADMIN_ROLE) returns (uint256) {
        if (_token == address(0)) {
            (bool sent, ) = _msgSender().call{value: _amount}("");
            require(sent, "Failed to send Ether");
        } else {
            IERC20Upgradeable(_token).transfer(address(_msgSender()), _amount);
        }

        return _amount;
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}
}
