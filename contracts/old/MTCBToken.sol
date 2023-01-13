//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * ERC20 Token.
 * Name: Metabike Coin
 * Symbol: MTCB
 * Total supply: 250 000 000 MTCB
 * Decimals: 18
 *
 * https://eips.ethereum.org/EIPS/eip-20
 */

contract MTCBToken is ERC20, Ownable {
    /**
     * @notice Mint 200 000 000 MTB tokens and send to owner
     */
    constructor() ERC20("Meta Crypto Bike", "MTCB") {
        _mint(owner(), 250000000 * (10**decimals()));
    }

    /**
     * @notice Burn your own tokens
     *
     * @param _amount Amount tokens for burn
     */
    function burnMyTokens(uint256 _amount) public {
        _burn(_msgSender(), _amount);
    }
}
