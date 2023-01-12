//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

//import "./NFT.sol";
//import "./Collection.sol";

contract Marketplace is Ownable, ReentrancyGuard, AccessControl {
    using SafeERC20 for IERC20;
    enum OrderType {
        ERC721order,
        ERC1155order
    }

    struct OrdersInfo {
        uint256 price;
        uint256 createdTime;
        uint256 selledTime;
        address target;
        uint256 nftId;
        uint256 amount;
        IERC20 paymentToken;
        address buyer;
        address seller;
        bool bought;
        bytes data;
    }

    mapping(bytes32 => OrdersInfo) public OrderbySalt;
    address[] public createdNFTs;

    event OrderBoughtSingleTarget(
        bytes32 order,
        uint256 _nftID,
        uint256 _amount,
        address buyer
    );
    event OrderCreated(bytes32 order, address seller);
    event OrderClosed(bytes32 order, address buyer);
    event LogReceived(address user);

    uint256 public totalSuccesfulOrder;
    uint256 public feePercent;
    address private feeRecipient;

    constructor(
        address owner,
        address _feeRecipient,
        uint256 _feePercent
    ) {
        owner = owner;
        feeRecipient = _feeRecipient;
        feePercent = _feePercent; //100 is 1 percent
    }

    receive() external payable {}

    fallback() external payable {
        require(msg.data.length == 0);
        emit LogReceived(msg.sender);
    }

    function closeOrder(bytes32 _createdOrder)
        public
        nonReentrant
        returns (bool)
    {
        OrdersInfo storage order = OrderbySalt[_createdOrder];
        uint256 amountToSeller = order.price - (feePercent * 100);
        order.paymentToken.transferFrom(
            address(msg.sender),
            address(this),
            order.price
        );
        order.paymentToken.transfer(order.seller, amountToSeller);

        if (order.amount > 1) {
            IERC1155(order.target).safeTransferFrom(
                address(this),
                address(msg.sender),
                order.nftId,
                order.amount,
                order.data
            );
        } else {
            IERC721(order.target).safeTransferFrom(
                address(this),
                address(msg.sender),
                order.nftId,
                order.data
            );
        }
        totalSuccesfulOrder++;
        order.buyer = msg.sender;
        order.selledTime = block.timestamp;
        order.bought = true;
        emit OrderClosed(_createdOrder, address(msg.sender));
        return true;
    }

    function buyERC1155(bytes32 _saltOrder, uint256 _amount)
        public
        nonReentrant
    {
        OrdersInfo storage order = OrderbySalt[_saltOrder];
        uint256 amountToSeller = order.price - (feePercent * 100 * _amount);
        order.paymentToken.transferFrom(
            address(msg.sender),
            address(this),
            order.price
        );
        order.paymentToken.transfer(order.seller, amountToSeller);
        IERC1155(order.target).balanceOf(address(this), order.nftId);
        IERC1155(order.target).safeTransferFrom(
            address(this),
            address(msg.sender),
            order.nftId,
            _amount,
            order.data
        );
        order.amount = order.amount - _amount;
        totalSuccesfulOrder++;
    }

    function createOrder(
        uint256 _price,
        address _target,
        uint256 _nftId,
        uint256 _amount,
        IERC20 _paymentToken,
        bytes calldata _data,
        bool collection
    ) public returns (bytes32) {
        require(_price != 0, "Cannot buy free");
        bytes32 _salt = keccak256(
            abi.encode(_target, _nftId, _amount, address(msg.sender))
        );
        OrdersInfo storage order = OrderbySalt[_salt];
        order.price = _price;
        order.createdTime = block.timestamp;
        order.selledTime = 0;
        order.target = _target;
        order.nftId = _nftId;
        order.amount = _amount;
        order.paymentToken = _paymentToken;
        order.buyer = 0x0000000000000000000000000000000000000000;
        order.seller = address(msg.sender);
        order.bought = false;
        order.data = _data;
        if (collection == true) {
            IERC1155(_target).safeTransferFrom(
                address(msg.sender),
                address(this),
                _nftId,
                _amount,
                _data
            );
        } else {
            IERC721(_target).safeTransferFrom(
                address(msg.sender),
                address(this),
                _nftId,
                _data
            );
        }
        emit OrderCreated(_salt, address(msg.sender));
        return _salt;
    }

    function checkOrderStatus(bytes32 _hashOrder) public view returns (bool) {
        OrdersInfo storage order = OrderbySalt[_hashOrder];
        return order.bought;
    }

    function checkMultipleOrderStatus(bytes32 _hashOrder)
        public
        view
        returns (uint256)
    {
        OrdersInfo storage order = OrderbySalt[_hashOrder];
        uint256 amount = order.amount;
        return amount;
    }

    function calculatePricePerTarget(bytes32 hashOrder, uint256 countOfTarget)
        public
        view
        returns (uint256)
    {
        OrdersInfo storage order = OrderbySalt[hashOrder];
        require(order.amount > 0);
        uint256 totalPrice = countOfTarget * order.price;
        return totalPrice;
    }

    function withdrawFee(IERC20 token, uint256 _amount)
        public
        onlyOwner
        returns (uint256)
    {
        token.transfer(address(msg.sender), _amount);
        return _amount;
    }
}
