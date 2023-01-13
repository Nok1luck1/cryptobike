//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";

contract CryptoBox is ERC721URIStorage, AccessControl {
    using Counters for Counters.Counter;
    Counters.Counter public globalCounter;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    address public owner;

    event Minted(uint256 _tokenId, string _link, address _to, uint256 _type);
    event Opened(uint256 _tokenId, address _from);

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        owner = msg.sender;
    }

    function mint(
        string memory _link,
        address _to,
        uint256 _type
    ) public onlyMinters {
        globalCounter.increment();
        _safeMint(_to, globalCounter.current());
        _setTokenURI(globalCounter.current(), _link);
        emit Minted(globalCounter.current(), _link, _to, _type);
    }

    function open(uint256 _tokenId) public {
        require(ownerOf(_tokenId) == msg.sender);
        _burn(_tokenId);
        emit Opened(_tokenId, msg.sender);
    }

    function addAdmin(address account) public virtual onlyAdmin {
        grantRole(DEFAULT_ADMIN_ROLE, account);
    }

    function removeAdmin(address _admin) public virtual onlyAdmin {
        revokeRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    function addMinter(address _minter) public virtual onlyAdmin {
        grantRole(MINTER_ROLE, _minter);
    }

    function removeMinter(address _minter) public virtual onlyAdmin {
        revokeRole(MINTER_ROLE, _minter);
    }

    modifier onlyAdmin() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Restricted to admins."
        );
        _;
    }

    modifier onlyMinters() {
        require(hasRole(MINTER_ROLE, msg.sender), "Restricted to minters.");
        _;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
