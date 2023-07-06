//SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import 'openzeppelin-solidity/contracts/token/ERC20/utils/SafeERC20.sol';
// import 'openzeppelin-solidity/contracts/token/ERC20/IERC20.sol';
// import "openzeppelin-solidity/contracts/access/Ownable.sol";
// import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";

// contract Staking is Ownable {

//     using SafeMath for uint256;
//     using SafeERC20 for IERC20;
//     IERC20 public token;

//     struct Deposit {
//         uint amount;
//         uint lockDate;
//         uint unlockDate;
//     }

//     mapping(uint => mapping(address => Deposit)) public deposits;

//     constructor(IERC20 _token) {
//         token = _token;
//     }

// //    0 - 6 month
// //    1 - 18 month
// //    2 - 36 month
//     function deposit(uint _amount, uint _plan) public {
//         token.safeTransferFrom(msg.sender, address(this), _amount);
//         if (deposits[_plan][msg.sender].lockDate != 0) {
//             require(block.timestamp < deposits[_plan][msg.sender].lockDate, "Deposit time has expired");
//         } else {
//             deposits[_plan][msg.sender].lockDate = block.timestamp + 61 days;
//             uint daysCount;
//             if (_plan == 0) daysCount = 183 days;
//             if (_plan == 1) daysCount =  547 days;
//             if (_plan == 2) daysCount = 1095 days;
//             deposits[_plan][msg.sender].unlockDate = block.timestamp + daysCount;
//         }

//         deposits[_plan][msg.sender].amount += _amount;
//     }
//     //    0 - 6 month
//     //    1 - 18 month
//     //    2 - 36 month
//     function withdraw(uint _plan) public {

// //        TODO array of plans
//         uint percent;
//         if (_plan == 0) percent = 3;
//         if (_plan == 1) percent = 6;
//         if (_plan == 2) percent = 10;

//         require(deposits[_plan][msg.sender].amount != 0, "Make a deposit first");
//         require(block.timestamp >= deposits[_plan][msg.sender].unlockDate, "Too early");
// //        TODO remix formula check
//         uint earned = deposits[_plan][msg.sender].amount * percent / 100 + deposits[_plan][msg.sender].amount;
//         require(token.balanceOf(address(this)) >= earned, "There is not enough tokens in the pool");

//         delete deposits[_plan][msg.sender];
//         token.safeTransfer(msg.sender, earned);
//     }

//     function checkDeposit(uint _plan) public view returns(uint) {
//         if (deposits[_plan][msg.sender].amount != 0) {
//             return deposits[_plan][msg.sender].amount;
//         } else {
//             return 0;
//         }
//     }

//     function getEarned(uint _plan) public view returns(uint) {
//         if (deposits[_plan][msg.sender].amount != 0) {
//             uint percent;
//             if (_plan == 0) percent = 3;
//             if (_plan == 1) percent = 6;
//             if (_plan == 2) percent = 10;

//             uint earned = deposits[_plan][msg.sender].amount * percent / 100 + deposits[_plan][msg.sender].amount;
//             return earned;
//         } else {
//             return 0;
//         }
//     }
// }
