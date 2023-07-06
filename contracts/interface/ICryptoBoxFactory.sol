// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)
pragma solidity ^0.8.0;

interface ICryptoBoxFactory {
    function mint(uint id, address to) external;

    function transferMTCB(uint amount, address to) external;

    function getRandomNumber() external;
}
