//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Pvp is IERC721Receiver, Ownable {
    IERC721 public nft;

    event Deposit(uint256 _tokenId, address _from);
    event Withdraw(uint256 _tokenId, address _to);

    mapping(uint256 => address) public owners;

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

    function depositNft(uint256 _tokenId) public {
        nft.safeTransferFrom(msg.sender, address(this), _tokenId);
        owners[_tokenId] = msg.sender;
        emit Deposit(_tokenId, msg.sender);
    }

    function setWinner(
        uint256 _tokenId1,
        uint256 _tokenId2,
        address _winner
    ) public onlyOwner {
        owners[_tokenId1] = _winner;
        owners[_tokenId2] = _winner;
    }

    function withdrawBike(uint256 _tokenId) public {
        require(owners[_tokenId] == msg.sender, "Wrong token id");
        nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        emit Withdraw(_tokenId, msg.sender);
    }

    function setNft(IERC721 _nft) public onlyOwner {
        nft = _nft;
    }
}
