//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract TESTERC1155 is ERC1155("advsdvsdvsdvsdv") {
    constructor() {
        _mint(msg.sender, 0, 1000, "0x00");
    }

    function mint(
        address to,
        uint256 id,
        uint256 amount
    ) public {
        _mint(to, id, amount, "0x00");
    }
}
