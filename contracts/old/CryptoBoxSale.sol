//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";

interface NFT is IERC721 {
    function mint(
        string memory _link,
        address _to,
        uint256 _type
    ) external;
}

contract CryptoBoxSale is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    NFT public nft;
    IERC20 public busd;
    address public paymentsOwner;
    uint256 public rateBusdBnb;
    bool public isBnbPaymentPossible;
    bool public isBusdPaymentPossible;

    struct Data {
        uint256 price;
        string link;
    }

    mapping(uint256 => Data) public prices;

    constructor(NFT _nft, IERC20 _busd) {
        nft = _nft;
        busd = _busd;
        paymentsOwner = msg.sender;
        isBnbPaymentPossible = true;
        isBusdPaymentPossible = false;
    }

    function buyBox(uint256 _boxType) public payable {
        require(isBnbPaymentPossible, "Payment method not available");
        require(prices[_boxType].price != 0, "Wrong box type sent");
        uint256 price = getBnbPrice(_boxType);
        require(price == msg.value, "Wrong amount of BNB sent");
        payable(paymentsOwner).transfer(msg.value);
        nft.mint(prices[_boxType].link, msg.sender, _boxType);
    }

    function buyBoxForBusd(uint256 _amount, uint256 _boxType) public {
        require(isBusdPaymentPossible, "Payment method not available");
        require(prices[_boxType].price != 0, "Wrong box type sent");
        uint256 inEther = prices[_boxType].price * 1 ether;
        require(inEther == _amount, "Wrong amount of BUSD sent");
        busd.transferFrom(msg.sender, paymentsOwner, inEther);
        nft.mint(prices[_boxType].link, msg.sender, _boxType);
    }

    function setPrices(Data[] memory _array) public onlyOwner {
        for (uint256 i = 0; i < _array.length; i++) {
            prices[i + 1].price = _array[i].price;
            prices[i + 1].link = _array[i].link;
        }
    }

    function setBusdBnbRate(uint256 _rate) public onlyOwner {
        rateBusdBnb = _rate;
    }

    function changeOwner(address _newOwner) public onlyOwner {
        paymentsOwner = _newOwner;
    }

    function getBnbPrice(uint256 _boxType) public returns (uint256) {
        require(prices[_boxType].price != 0, "Wrong box type sent");
        return prices[_boxType].price * rateBusdBnb;
    }

    function setIsBnbPaymentPossible(bool _val) public onlyOwner {
        isBnbPaymentPossible = _val;
    }

    function setIsBusdPaymentPossible(bool _val) public onlyOwner {
        isBusdPaymentPossible = _val;
    }
}
