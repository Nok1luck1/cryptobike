//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenExchange is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    IERC20 public token;
    address public holder;
    uint256 public amountLimit;

    event Deposit(uint256 _amount, address _from);

    constructor(
        IERC20 _token,
        address _holder,
        uint256 _amountLimit
    ) {
        token = _token;
        holder = _holder;
        amountLimit = _amountLimit * 1 ether;
    }

    function depositToken(uint256 _amount) public {
        require(
            _amount >= amountLimit,
            "You have sent less tokens than needed for the exchange"
        );
        token.transferFrom(msg.sender, holder, _amount);
        emit Deposit(_amount, msg.sender);
    }

    function setNewHolder(address _holder) public onlyOwner {
        holder = _holder;
    }

    function setNewLimit(uint256 _amountLimit) public onlyOwner {
        amountLimit = _amountLimit * 1 ether;
    }
}
