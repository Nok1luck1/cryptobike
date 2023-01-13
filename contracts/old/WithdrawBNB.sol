//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

//import 'openzeppelin-solidity/contracts/token/ERC20/utils/SafeERC20.sol';
//import 'openzeppelin-solidity/contracts/token/ERC20/IERC20.sol';

contract WithdrawBNB is Ownable {
    using SafeMath for uint256;
    //    using SafeERC20 for IERC20;
    //    IERC20 public busd;

    struct Data {
        address user;
        uint256 amount;
    }

    mapping(address => uint256) public whiteList;

    //    constructor(IERC20 _busd) {
    //        busd = _busd;
    //    }

    function withdraw(uint256 _amount) public {
        require(whiteList[msg.sender] >= _amount, "Wrong amount sent");
        require(
            address(this).balance >= _amount,
            "Contract does not have enough funds. Please contact support"
        );
        payable(msg.sender).transfer(whiteList[msg.sender]);
        whiteList[msg.sender] = whiteList[msg.sender] - _amount;
    }

    function fillContract() public payable onlyOwner {
        payable(address(this)).transfer(msg.value);
    }

    function setWhiteList(Data[] memory _array) public onlyOwner {
        for (uint256 i = 0; i < _array.length; i++) {
            whiteList[_array[i].user] = _array[i].amount;
        }
    }
}
