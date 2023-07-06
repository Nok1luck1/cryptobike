//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IFactoryMarket {
    function accountAddress(address user) external returns (address account);

    function userHasAccount(address user) external returns (address account);
}
