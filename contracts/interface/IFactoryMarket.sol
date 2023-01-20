//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
enum OrderType {
    ERC721,
    ERC1155,
    Account
}
struct OrderInfo {
    OrderType typeOrder;
    address target;
    address paymentToken;
    address seller;
    uint256 nftId;
    uint256 amount;
    uint256 price;
    bytes data;
}

interface IFactoryMarket {
    function accountAddress(address user) external returns (address account);

    function userHasAccount(address user) external returns (address account);

    function createOrder(
        OrderType _orderType,
        address _target,
        address _paymentToken,
        bytes32 _hashOrder,
        bytes calldata _data,
        uint256 _price,
        uint256 _nftID,
        uint256 _amount
    ) external;
}
