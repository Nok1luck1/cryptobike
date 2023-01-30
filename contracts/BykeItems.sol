//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";

contract BykeItems is ERC1155, ERC1155URIStorage, AccessControl {
    constructor() ERC1155("") {
        // setURI();
    }

    function mint(
        uint256 id,
        uint256 amount,
        address to
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _mint(to, id, amount, "");
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

    function setURI(uint256 id, string memory urL)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _setURI(id, urL);
    }
}
