// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)
pragma solidity ^0.8.0;
struct DataWithdraw {
    address sender;
    address receiver;
    uint256 expirationDate;
    address[] nfts;
    uint256[] idsNFTs;
    uint256[] partIDs;
    uint256[] amounts;
}
struct UserRaceParams {
    address sender;
    address receiver;
    uint256 expirationDate;
    address[] erc721;
    uint256[] id721;
    uint256[] itemsId;
    uint256[] itemsAmount;
}

interface IPvpV2 {
    function withdrawBalance(DataWithdraw memory params) external;

    function depositItems(UserRaceParams memory params) external;
}
