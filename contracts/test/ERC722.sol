//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ERC722 is ERC721("TEST2", "TST2") {
    using Counters for Counters.Counter;

    constructor() {
        _safeMint(msg.sender, 0);
    }

    function mint(address to, uint256 id) public {
        _mint(to, id);
    }

    function ididnahuy() public returns (uint256) {
        return 1;
    }
}
