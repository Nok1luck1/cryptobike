//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./interface/IFactoryMarket.sol";

contract FreeByke is ERC721URIStorage, AccessControl {
    using Counters for Counters.Counter;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    string public url;
    address public factory;
    Counters.Counter public _globalCounter;

    mapping(address => bool) public userMinted;

    constructor(string memory _url) ERC721("FReeByke", "CFB") {
        factory = 0xB06c856C8eaBd1d8321b687E188204C1018BC4E5;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        url = _url;
    }

    function freeMint() public {
        require(userMinted[msg.sender] == false, "Cant mint more");
        require(balanceOf(address(this)) == 0, "You already have free byke");
        _safeMint(msg.sender, _globalCounter.current());
        _globalCounter.increment();
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        require(
            IFactoryMarket(factory).userHasAccount(msg.sender) != address(0)
        );
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not token owner or approved"
        );
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(
            IFactoryMarket(factory).userHasAccount(msg.sender) != address(0)
        );
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not token owner or approved"
        );
        _safeTransfer(from, to, tokenId, data);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function setUrl(string memory _url) public onlyRole(DEFAULT_ADMIN_ROLE) {
        url = _url;
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
