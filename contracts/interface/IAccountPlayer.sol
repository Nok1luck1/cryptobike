//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

interface IAccountPlayer {
    function setBlock(bool status) external;

    function grandRoleNewOwner(address newOwner) external;

    function sellOwnership(address newOwner) external;

    function currentowner() external returns (address);

    function initialize(address owner) external;

    function setPause(bool status) external;
}
