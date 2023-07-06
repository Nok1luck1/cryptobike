//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract TESTERC721 is ERC721("TEST", "TST") {
    using Counters for Counters.Counter;

    constructor() {
        _safeMint(msg.sender, 1);
    }

    function mint(address to, uint256 id) public {
        _mint(to, id);
    }
}
