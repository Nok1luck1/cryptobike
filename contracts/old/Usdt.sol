pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Usdt is ERC20, Ownable {
    constructor() ERC20("USDT Token", "USDT") {
        _mint(owner(), 500000000 * (10 ** decimals()));
    }
}
