//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IAccountPlayer {
    function setBlock(bool status) external;

    function sellOwnership(address newOwner) external;

    function currentowner() external returns (address);

    function initialize(
        address _owner,
        address market,
        uint256 userID
    ) external;

    function setPause(bool status) external;

    function withdraw721(
        address nft,
        address _to,
        uint256 _tokenId
    ) external;

    function witdhraw1155(
        address collection,
        address _to,
        uint256 _tokenId,
        uint256 amount,
        bytes calldata _data
    ) external;
}
