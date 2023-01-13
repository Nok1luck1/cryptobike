//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface NFT is IERC721 {
    function getItemPrice(uint256 _itemType) external view returns (uint256);

    function mint(address _to, uint256 _itemType) external;
}

contract MarketplaceItems is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    IERC20 public token;
    IERC20 public usdt;
    NFT public nft;
    address public paymentsOwner;
    uint256 public rateUsdtBnb;
    uint256 public rateUsdtToken;
    bool public isBnbPaymentPossible;
    bool public isUsdtPaymentPossible;
    bool public isTokenPaymentPossible;

    constructor(
        IERC20 _token,
        IERC20 _usdt,
        NFT _nft
    ) {
        token = _token;
        usdt = _usdt;
        nft = _nft;
        paymentsOwner = msg.sender;
        isBnbPaymentPossible = true;
        isUsdtPaymentPossible = false;
        isTokenPaymentPossible = false;
    }

    function buyNft(uint256 _itemType) public payable {
        require(isBnbPaymentPossible == true, "Payment method not available");
        uint256 price = getBnbPrice(_itemType);
        require(price == msg.value, "Wrong amount of BNB sent");
        payable(paymentsOwner).transfer(msg.value);
        nft.mint(msg.sender, _itemType);
    }

    function buyNftForUsdt(uint256 _amount, uint256 _itemType) public {
        require(isUsdtPaymentPossible == true, "Payment method not available");
        uint256 price = getPrice(_itemType);
        require(price == _amount, "Wrong amount of tokens sent");
        usdt.transferFrom(msg.sender, paymentsOwner, _amount);
        nft.mint(msg.sender, _itemType);
    }

    function buyNftForToken(uint256 _amount, uint256 _itemType) public {
        require(isTokenPaymentPossible == true, "Payment method not available");
        uint256 price = getTokenPrice(_itemType);
        require(price == _amount, "Wrong amount of tokens sent");
        token.transferFrom(msg.sender, paymentsOwner, _amount);
        nft.mint(msg.sender, _itemType);
    }

    function setNft(NFT _nft) public onlyOwner {
        nft = _nft;
    }

    function setToken(IERC20 _token) public onlyOwner {
        token = _token;
    }

    function getPrice(uint256 _itemType) public view returns (uint256) {
        return nft.getItemPrice(_itemType) * 1 ether;
    }

    function getBnbPrice(uint256 _itemType) public view returns (uint256) {
        return nft.getItemPrice(_itemType) * rateUsdtBnb;
    }

    function getTokenPrice(uint256 _itemType) public view returns (uint256) {
        return nft.getItemPrice(_itemType) * rateUsdtToken;
    }

    function setIsBnbPaymentPossible(bool _val) public onlyOwner {
        isBnbPaymentPossible = _val;
    }

    function setIsUsdtPaymentPossible(bool _val) public onlyOwner {
        isUsdtPaymentPossible = _val;
    }

    function setIsTokenPaymentPossible(bool _val) public onlyOwner {
        isTokenPaymentPossible = _val;
    }

    function setUsdtBnbRate(uint256 _rate) public onlyOwner {
        rateUsdtBnb = _rate;
    }

    function setUsdtTokenRate(uint256 _rate) public onlyOwner {
        rateUsdtToken = _rate;
    }

    function changeOwner(address _newOwner) public onlyOwner {
        paymentsOwner = _newOwner;
    }
}
