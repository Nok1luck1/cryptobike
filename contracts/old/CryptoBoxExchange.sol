//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";

interface NFT is IERC721 {
    function mint(
        string memory _link,
        address _to,
        uint256 _type
    ) external;
}

contract CryptoBoxExchange is Ownable, IERC721Receiver {
    using SafeMath for uint256;
    IERC721 public oldBox;
    NFT public newBox;
    struct BOX {
        uint256 id;
        address owner;
        string link;
        uint256 boxType;
    }
    mapping(uint256 => BOX) public whiteList;

    constructor(IERC721 _oldBox, NFT _newBox) {
        oldBox = _oldBox;
        newBox = _newBox;
    }

    function open(uint256 _boxId) public {
        require(whiteList[_boxId].owner == msg.sender, "It's not your box");
        oldBox.safeTransferFrom(msg.sender, address(this), _boxId);
        newBox.mint(
            whiteList[_boxId].link,
            msg.sender,
            whiteList[_boxId].boxType
        );
        delete whiteList[_boxId];
    }

    function setDefaults(BOX[] memory _array) public onlyOwner {
        for (uint256 i = 0; i < _array.length; i++) {
            whiteList[_array[i].id].owner = _array[i].owner;
            whiteList[_array[i].id].link = _array[i].link;
            whiteList[_array[i].id].boxType = _array[i].boxType;
        }
    }

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes memory _data
    ) public override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
