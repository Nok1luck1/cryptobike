//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IAccountPlayer {
    function setBlock(bool status) external;

    //function grantRole(bytes32 role, address target) external;

    function grandRoleNewOwner(address newOwner) external;

    function sellOwnership(address newOwner) external;

    function currentowner() external returns (address);

    function initialize(address _owner, uint256 userID) external;

    function setPause(bool status) external;
}
