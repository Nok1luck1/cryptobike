//SPDX-License-Identifier: UNLICENSED
<<<<<<< HEAD
pragma solidity ^0.8.0;
=======
pragma solidity 0.8.17;
>>>>>>> 531b888dd12c83034dacc7e23a8f7ed4ae8d4041

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";

contract FreeCollection is ERC1155, AccessControl, ERC1155URIStorage {
    mapping(address => mapping(uint256 => bool)) public userMinted;
    uint256 public freeAccessID;

    constructor(uint256 id, string memory url) ERC1155("") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        setURI(id, url);
    }

    function setURI(uint256 id, string memory urL)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _setURI(id, urL);
    }

    function setNewFreeItem(uint256 id) public onlyRole(DEFAULT_ADMIN_ROLE) {
        freeAccessID = id;
    }

    function freeMint() public {
        require(
            userMinted[msg.sender][freeAccessID] == false,
            "Cant mint more"
        );
        _mint(msg.sender, freeAccessID, 1, "");
    }

    function mint(
        address _to,
        uint256 _tokenId,
        uint256 _amount,
        string memory urL,
        bytes memory _data
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        setURI(_tokenId, urL);
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
