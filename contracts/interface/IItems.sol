// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)
pragma solidity ^0.8.0;

interface IItems {
    function mint(uint256 id, uint256 amount, address to) external;
}
