//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";

contract Collection is ERC1155, AccessControl, ERC1155URIStorage {
    mapping(address => mapping(uint256 => bool)) public userMinted;
    uint256 public freeAccessID;

    constructor(string memory url) ERC1155("") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setBaseURI(url);
        mint(msg.sender, 0, 1, "");
    }

    function freeMint() public {
        require(
            userMinted[msg.sender][freeAccessID] == false,
            "Cant mint more"
        );
        require(
            balanceOf(address(this), freeAccessID) == 0,
            "You already have free byke"
        );
        _mint(msg.sender, freeAccessID, 1, "");
    }

    function mint(
        address _to,
        uint256 _tokenId,
        uint256 _amount,
        bytes memory _data
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        string memory urL = abi.decode(_data, (string));
        _setURI(_tokenId, urL);
        _mint(_to, _tokenId, _amount, _data);
    }

    function mint(
        address to,
        uint256 tokenId,
        uint256 amount
    ) public onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        _mint(to, tokenId, amount, "");
        return true;
    }

    function uri(uint256 tokenID)
        public
        view
        virtual
        override(ERC1155URIStorage, ERC1155)
        returns (string memory)
    {
        return ERC1155URIStorage.uri(tokenID);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public override {
        safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public override onlyRole(DEFAULT_ADMIN_ROLE) {
        safeBatchTransferFrom(from, to, ids, amounts, data);
    }
}
