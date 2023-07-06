//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import "./interface/IERC4907.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

contract RentMarket is
    ERC721HolderUpgradeable,
    ERC1155HolderUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;
    enum StatusOrder {
        OPEN,
        IN_USE,
        ClOSED,
        ERC721,
        ERC1155
    }
    uint256 public fee;
    mapping(bytes32 => RentOrder) public orders;
    mapping(bytes32 => OrderInfo) public OrderByHash;
    //set maxDuration in count of hours
    struct RentOrder {
        StatusOrder status;
        address creator;
        address renter;
        address paymentToken;
        address tokenTarget;
        address items;
        bytes data;
        uint256 tokenId;
        uint256 pricePerHour;
        uint256 maxDuration;
        uint256 expirationTime;
        uint[] itemsIDs;
        uint[] amounts;
    }
    struct OrderInfo {
        StatusOrder typeOrder;
        address target;
        address paymentToken;
        address seller;
        bytes data;
        uint256 nftId;
        uint256 amount;
        uint256 price;
    }

    event NewRentableItem(
        bytes32 hashOrd,
        address creator,
        address target,
        uint targetID,
        uint maxDurationHour,
        address items,
        uint[] ids,
        address paymentToken,
        uint256 price
    );
    event RentedItem(
        address creator,
        address renter,
        uint256 endTime,
        address target,
        uint targetID
    );
    event RentDeleted(address creator, address target, bytes32 orderHash);
    event CreatedAccount(
        address User,
        address generatedAccount,
        uint64 accountId
    );
    event CreatedOrder(
        address target,
        address creator,
        bytes32 hashOrder,
        StatusOrder typeOrder
    );
    event CancelOrder(
        address target,
        address canceler,
        bytes32 hashOrder,
        StatusOrder typeOrder
    );
    event BuyInOrder(
        address target,
        address buyer,
        bytes32 hashOrder,
        StatusOrder typeOrder
    );
    event PaymentSended(
        address seller,
        address buyer,
        address target,
        uint256 amountToSeller
    );

    receive() external payable {}

    fallback() external payable {}

    function initialize(address owner) public initializer {
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(DEFAULT_ADMIN_ROLE, owner);
        _setupRole(DEFAULT_ADMIN_ROLE, owner);
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
    }

    function createOrder(
        StatusOrder _orderType,
        address _target,
        address _paymentToken,
        bytes32 _hashOrder,
        bytes calldata _data,
        uint256 _price,
        uint256 _nftID,
        uint256 _amount
    ) public {
        require(_price != 0, "CRO1");
        require(_target != address(0), "CRO2");
        if (_orderType == StatusOrder.ERC721) {
            IERC721Upgradeable(_target).safeTransferFrom(
                msg.sender,
                address(this),
                _nftID,
                _data
            );
            OrderInfo storage order = OrderByHash[_hashOrder];
            order.amount = _amount;
            order.typeOrder = _orderType;
            order.data = _data;
            order.nftId = _nftID;
            order.paymentToken = _paymentToken;
            order.price = _price;
            order.seller = msg.sender;
            order.target = _target;
        } else if (_orderType == StatusOrder.ERC1155) {
            IERC1155Upgradeable(_target).safeTransferFrom(
                msg.sender,
                address(this),
                _nftID,
                _amount,
                _data
            );
            OrderInfo storage order = OrderByHash[_hashOrder];
            order.amount = _amount;
            order.data = _data;
            order.typeOrder = _orderType;
            order.nftId = _nftID;
            order.paymentToken = _paymentToken;
            order.price = _price;
            order.seller = msg.sender;
            order.target = _target;
        }
        emit CreatedOrder(_target, msg.sender, _hashOrder, _orderType);
    }

    function buyFromOrder(
        bytes32 hashOrder,
        uint256 _amount,
        address receiver
    ) public payable nonReentrant {
        OrderInfo storage _order = OrderByHash[hashOrder];
        uint256 amountToPayment = _order.price * _amount;
        uint256 amountToSeller = calculateFee(amountToPayment);
        if (_order.paymentToken == address(0)) {
            AddressUpgradeable.sendValue(
                payable(_order.seller),
                amountToSeller
            );
        } else {
            IERC20Upgradeable(_order.paymentToken).safeTransferFrom(
                _msgSender(),
                address(this),
                _order.price
            );
            IERC20Upgradeable(_order.paymentToken).safeTransfer(
                _order.seller,
                amountToSeller
            );
        }
        emit PaymentSended(
            _order.seller,
            _msgSender(),
            _order.target,
            amountToSeller
        );
        if (_order.typeOrder == StatusOrder.ERC721) {
            IERC721Upgradeable(_order.target).safeTransferFrom(
                address(this),
                msg.sender,
                _order.nftId,
                _order.data
            );
            emit BuyInOrder(
                _order.target,
                _msgSender(),
                hashOrder,
                _order.typeOrder
            );
            delete OrderByHash[hashOrder];
        } else if (_order.typeOrder == StatusOrder.ERC1155) {
            require(_order.amount >= _amount, "Cant buy more than sale");
            IERC1155Upgradeable(_order.target).safeTransferFrom(
                address(this),
                receiver,
                _order.nftId,
                _amount,
                _order.data
            );
            uint256 newAmount = _order.amount - _amount;
            _order.amount = newAmount;
            emit BuyInOrder(
                _order.target,
                receiver,
                hashOrder,
                _order.typeOrder
            );
            if (_order.amount == 0) {
                delete OrderByHash[hashOrder];
            }
        }
    }

    function cancelOrder(bytes32 hashOrder, address receiveTarget) public {
        OrderInfo storage order = OrderByHash[hashOrder];
        require(_msgSender() == order.seller);
        if (order.typeOrder == StatusOrder.ERC721) {
            IERC721Upgradeable(order.target).safeTransferFrom(
                address(this),
                receiveTarget,
                order.nftId,
                order.data
            );
        } else if (order.typeOrder == StatusOrder.ERC1155) {
            IERC1155Upgradeable(order.target).safeTransferFrom(
                address(this),
                receiveTarget,
                order.nftId,
                order.amount,
                order.data
            );
        }
        emit CancelOrder(
            order.target,
            _msgSender(),
            hashOrder,
            order.typeOrder
        );
        delete OrderByHash[hashOrder];
    }

    function putOnRent(
        RentOrder memory _params,
        bytes32 orderHash
    ) public whenNotPaused {
        require(
            checkSupportRent(_params.tokenTarget) == true,
            "Target does not support rent"
        );
        require(
            orders[orderHash].tokenTarget == address(0),
            "Order with that hash alreeady exists"
        );
        IERC721Upgradeable(_params.tokenTarget).safeTransferFrom(
            _msgSender(),
            address(this),
            _params.tokenId,
            _params.data
        );
        if (_params.items != address(0)) {
            IERC1155Upgradeable(_params.items).safeBatchTransferFrom(
                _msgSender(),
                address(this),
                _params.itemsIDs,
                _params.amounts,
                ""
            );
        }

        RentOrder storage order = orders[orderHash];
        order.status = StatusOrder.OPEN;
        order.creator = _msgSender();
        order.renter = address(0);
        order.paymentToken = _params.paymentToken;
        order.tokenTarget = _params.tokenTarget;
        order.data = _params.data;
        order.tokenId = _params.tokenId;
        order.pricePerHour = _params.pricePerHour;
        order.maxDuration = _params.maxDuration;
        order.expirationTime = 0;
        emit NewRentableItem(
            orderHash,
            _msgSender(),
            _params.tokenTarget,
            _params.tokenId,
            _params.maxDuration,
            _params.items,
            _params.itemsIDs,
            _params.paymentToken,
            _params.pricePerHour
        );
    }

    function rent(
        bytes32 orderHash,
        uint hoursRent
    ) public payable whenNotPaused {
        RentOrder storage order = orders[orderHash];
        require(order.status != StatusOrder.ClOSED, "order closed to rent");
        require(
            order.expirationTime < block.timestamp,
            "Old rent does not closed"
        );
        require(
            hoursRent <= order.maxDuration,
            "Cant take longer than maxDuration"
        );
        uint totalPrice = (hoursRent * order.pricePerHour);
        uint duration = 3600 * hoursRent;
        if (order.paymentToken == 0x0000000000000000000000000000000000000000) {
            AddressUpgradeable.sendValue(payable(address(this)), totalPrice);
            AddressUpgradeable.sendValue(
                payable(order.creator),
                (totalPrice / 100) * 97
            );
        } else {
            IERC20Upgradeable(order.paymentToken).safeTransferFrom(
                _msgSender(),
                address(this),
                totalPrice
            );
            IERC20Upgradeable(order.paymentToken).safeTransfer(
                order.creator,
                (totalPrice / 100) * 97
            );
        }

        IERC4907(order.tokenTarget).setUser(
            order.tokenId,
            _msgSender(),
            uint64(block.timestamp + duration)
        );
        order.status = StatusOrder.IN_USE;
        order.expirationTime = block.timestamp + duration;
        order.renter = _msgSender();
        emit RentedItem(
            order.creator,
            _msgSender(),
            order.expirationTime,
            order.tokenTarget,
            order.tokenId
        );
    }

    function closeRentOrder(
        bytes32 orderHash,
        address withdrawTo
    ) public nonReentrant {
        RentOrder storage order = orders[orderHash];
        require(order.creator == _msgSender(), "Cant close another order");
        if (order.status == StatusOrder.OPEN) {
            if (order.renter == address(0)) {
                IERC721Upgradeable(order.tokenTarget).safeTransferFrom(
                    address(this),
                    withdrawTo,
                    order.tokenId,
                    order.data
                );
                order.status = StatusOrder.ClOSED;
            } else {
                order.status = StatusOrder.ClOSED;
            }
        } else if (order.status == StatusOrder.IN_USE) {
            if (order.expirationTime < block.timestamp) {
                IERC721Upgradeable(order.tokenTarget).safeTransferFrom(
                    address(this),
                    withdrawTo,
                    order.tokenId,
                    order.data
                );
                IERC1155Upgradeable(order.items).safeBatchTransferFrom(
                    address(this),
                    withdrawTo,
                    order.itemsIDs,
                    order.amounts,
                    ""
                );
                order.status = StatusOrder.ClOSED;
            } else {
                order.status = StatusOrder.ClOSED;
            }
        } else if (order.status == StatusOrder.ClOSED) {
            IERC721Upgradeable(order.tokenTarget).safeTransferFrom(
                address(this),
                withdrawTo,
                order.tokenId,
                order.data
            );
            IERC1155Upgradeable(order.items).safeBatchTransferFrom(
                address(this),
                withdrawTo,
                order.itemsIDs,
                order.amounts,
                ""
            );
        }
    }

    function withdrawClosed(bytes32 orderHash, address withdraw) public {
        RentOrder storage order = orders[orderHash];
        require(order.status == StatusOrder.ClOSED);
        require(order.expirationTime < block.timestamp);
        IERC721Upgradeable(order.tokenTarget).safeTransferFrom(
            address(this),
            withdraw,
            order.tokenId,
            order.data
        );
        emit RentDeleted(order.creator, order.tokenTarget, orderHash);
        delete orders[orderHash];
    }

    function checkSupportRent(address target) public returns (bool) {
        (bool success, ) = target.call(
            abi.encodeWithSignature(
                "supportsInterface(bytes4)",
                type(IERC4907).interfaceId
            )
        );
        return success;
    }

    function calculateFee(uint256 bill) public view returns (uint256) {
        uint256 amountFee = (bill / 1000) * fee;
        uint256 sendToSeller = bill - amountFee;
        return sendToSeller;
    }

    function withdrawFee(
        address _token,
        uint256 _amount
    ) public onlyRole(DEFAULT_ADMIN_ROLE) returns (uint256) {
        IERC20Upgradeable(_token).transfer(address(_msgSender()), _amount);
        return _amount;
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(AccessControlUpgradeable, ERC1155ReceiverUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}
}
