//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";

contract CollectionExchange is IERC721Receiver, Ownable {
    IERC721 public nft;

    struct NFT {
        address owner;
        uint256 price;
    }

    mapping(uint256 => NFT) public tokensForSale;

    event NFTForSale(uint256 _tokenId, address _from, uint256 _price);
    event NFTSold(uint256 _tokenId, address _to);
    event NFTReturned(uint256 _tokenId, address _to);

    constructor(IERC721 _nft) {
        nft = _nft;
    }

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes memory _data
    ) public override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function buyNft(uint256 _nftId) public payable {
        require(tokensForSale[_nftId].owner != msg.sender, "It's your nft");
        require(tokensForSale[_nftId].price > 0, "Wrong nft id has been sent");
        require(
            tokensForSale[_nftId].price == msg.value,
            "Wrong amount of BNB has been sent"
        );
        payable(tokensForSale[_nftId].owner).transfer(msg.value);
        nft.safeTransferFrom(address(this), msg.sender, _nftId);
        emit NFTSold(_nftId, msg.sender);
        delete tokensForSale[_nftId];
    }

    function sellNft(uint256 _nftId, uint256 _price) public {
        tokensForSale[_nftId].owner = msg.sender;
        tokensForSale[_nftId].price = _price;
        nft.safeTransferFrom(msg.sender, address(this), _nftId);
        emit NFTForSale(_nftId, msg.sender, _price);
    }

    function getBack(uint256 _nftId) public {
        require(
            tokensForSale[_nftId].owner == msg.sender,
            "Wrong nft id has been sent"
        );
        nft.safeTransferFrom(address(this), msg.sender, _nftId);
        emit NFTReturned(_nftId, msg.sender);
        delete tokensForSale[_nftId];
    }

    function setNft(IERC721 _nft) public onlyOwner {
        nft = _nft;
    }

    function setDefaults(NFT[] memory _array) public onlyOwner {
        for (uint256 i = 0; i < _array.length; i++) {
            tokensForSale[i + 1].price = _array[i].price;
            tokensForSale[i + 1].owner = _array[i].owner;
        }
    }
}
