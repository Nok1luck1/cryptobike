//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./interface/IERC4907.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

contract CryptoBike is
    ERC721Upgradeable,
    ERC721URIStorageUpgradeable,
    UUPSUpgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    IERC4907
{
    using CountersUpgradeable for CountersUpgradeable.Counter;
    struct UserInfo {
        address user; // address of user role
        uint64 expires; // unix timestamp, user expires
    }
    bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
    mapping(uint256 => UserInfo) internal _users;

    function initialize(string calldata _name, string calldata _string)
        external
        initializer
    {
        __ERC721_init(_name, _string);
        __ERC721URIStorage_init();
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        grantRole(
            DEFAULT_ADMIN_ROLE,
            0x3f4F5d9971c265a7485540207023EA4B68Af6dc6
        );
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();
    }

    function mint(uint256 tokenId, address _to) public {
        _mint(_to, tokenId);
    }

    function setURI(uint256 tokenID, string calldata _tokenURI) public {
        _setTokenURI(tokenID, _tokenURI);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
    {
        super._burn(tokenId);
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

    function userOf(uint256 tokenId) public view virtual returns (address) {
        if (uint256(_users[tokenId].expires) >= block.timestamp) {
            return _users[tokenId].user;
        } else {
            return address(0);
        }
    }

    function userExpires(uint256 tokenId)
        public
        view
        virtual
        returns (uint256)
    {
        return _users[tokenId].expires;
    }

    // The following functions are overrides required by Solidity.

    /// @dev See {IERC165-supportsInterface}.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return
            interfaceId == type(IERC4907).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        super._beforeTokenTransfer(from, to, tokenId, 1);
        if (from != to && _users[tokenId].user != address(0)) {
            delete _users[tokenId];
            emit UpdateUser(tokenId, address(0), 0);
        }
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {}
}
