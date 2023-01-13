//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

interface IAccountPlayer {
    function setBlock() external;

    function grandRoleNewOwner(address newOwner) external;

    function initialize(address owner) external;

    function setPause() external;
}
