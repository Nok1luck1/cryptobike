//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TEST is ERC20("BUSD", "USD") {
    constructor() {
        mint(msg.sender, 100000000 * 10**18);
        mint(0x5C5193544Fce3f8407668D451b20990303cc692a, 1000000 * 10**18);
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
