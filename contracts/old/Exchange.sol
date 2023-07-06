//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Exchange is IERC721Receiver, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    IERC20 public token;

    event Received(address _operator, address _from, uint256 _tokenId);

    struct Price {
        uint256 price;
    }

    mapping(address => mapping(uint256 => Price)) public bikes;
    mapping(address => mapping(uint256 => Price)) public items;

    constructor(IERC20 _token) {
        token = _token;
    }

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes memory _data
    ) public override returns (bytes4) {
        emit Received(_operator, _from, _tokenId);
        return this.onERC721Received.selector;
    }

    function loadNft(
        address _operator,
        uint256 _tokenId,
        uint256 _type,
        uint256 _price
    ) public {
        IERC721 NFT = IERC721(_operator);
        NFT.transferFrom(msg.sender, address(this), _tokenId);
        if (_type == 0) {
            bikes[_operator][_tokenId].price = _price;
        }
        if (_type == 1) {
            items[_operator][_tokenId].price = _price;
        }
    }

    function buyNft(
        address _operator,
        uint256 _tokenId,
        uint256 _type,
        uint256 _amount
    ) public payable {
        uint256 price;
        if (_type == 0) {
            require(
                bikes[_operator][_tokenId].price == _amount,
                "Wrong amount of tokens sent"
            );
            price = bikes[_operator][_tokenId].price;
        }
        if (_type == 1) {
            require(
                items[_operator][_tokenId].price == _amount,
                "Wrong amount of tokens sent"
            );
            price = bikes[_operator][_tokenId].price;
        }
        token.safeTransferFrom(msg.sender, address(this), price);
        sendNft(_operator, _tokenId, msg.sender, _type);
    }

    function sendNft(
        address _operator,
        uint256 _tokenId,
        address _to,
        uint256 _type
    ) private {
        IERC721 NFT = IERC721(_operator);
        NFT.transferFrom(address(this), _to, _tokenId);
        if (_type == 0) {
            delete bikes[_operator][_tokenId];
        }
        if (_type == 1) {
            delete items[_operator][_tokenId];
        }
    }
}
