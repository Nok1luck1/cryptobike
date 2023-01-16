//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TESTERC721 is ERC721("TEST", "TST") {
    constructor() {
        _safeMint(msg.sender, 1);
    }

    //     function mint(address to, uint256 amount) public {
    //         _mint(to, amount);
    //     }
}
