//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
enum StatusOrder {
    OPEN,
    IN_USE,
    ClOSED,
    ERC721,
    ERC1155
}

interface IMarket {
    function createOrder(
        StatusOrder _orderType,
        address _target,
        address _paymentToken,
        bytes32 _hashOrder,
        bytes calldata _data,
        uint256 _price,
        uint256 _nftID,
        uint256 _amount
    ) external payable;
}
