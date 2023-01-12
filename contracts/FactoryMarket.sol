//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import "./AccountPlayer.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

// import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

contract FactoryMarket is
    ReentrancyGuard,
    Initializable,
    UUPSUpgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;
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
    //fee 3%
    uint256 public fee; //1% = 10
    mapping(bytes32 => OrderInfo) public OrderByHash;
    mapping(address => address) public accountAddress;
    event CreatedAccount(address User, address generatedAccount);
    event CreatedOrder(
        address target,
        address creator,
        bytes32 hashOrder,
        OrderType order
    );

    function generateAccount() public {
        address createdAccount;
        bytes memory bytecodeAccount = type(AccountPlayer).creationCode;
        bytes32 salt = keccak256(
            abi.encodePacked(address(this), address(msg.sender))
        );
        assembly {
            {
                createdAccount := create2(
                    0,
                    add(bytecodeAccount, 0x20),
                    mload(bytecodeAccount),
                    salt
                )
            }
        }
        require(createdAccount != address(0), "Create2: Failed on deploy");
        accountAddress[msg.sender] = createdAccount;
        emit CreatedAccount(address(msg.sender), createdAccount);
    }

    function createOrder(
        OrderType _orderType,
        address _target,
        address _paymentToken,
        bytes32 _hashOrder,
        bytes calldata _data,
        uint256 _price,
        uint256 _nftID,
        uint256 _amount
    ) public payable {
        require(_price != 0, "CRO1");
        require(_target != address(0), "CRO2");
        if (_paymentToken == address(0)) {
            require(msg.value == _amount, "CRO3");
        }
        if (_orderType == OrderType.ERC721) {
            IERC721(_target).safeTransferFrom(
                msg.sender,
                address(this),
                _nftID,
                _data
            );
            OrderInfo storage order = OrderByHash[_hashOrder];
            order.amount = _amount;
            order.data = _data;
            order.nftId = _nftID;
            order.paymentToken = _paymentToken;
            order.price = _price;
            order.seller = msg.sender;
            order.target = _target;
        } else if (_orderType == OrderType.ERC1155) {
            IERC1155(_target).safeTransferFrom(
                msg.sender,
                address(this),
                _nftID,
                _amount,
                _data
            );
            OrderInfo storage order = OrderByHash[_hashOrder];
            order.amount = _amount;
            order.data = _data;
            order.nftId = _nftID;
            order.paymentToken = _paymentToken;
            order.price = _price;
            order.seller = msg.sender;
            order.target = _target;
        } else if (_orderType == OrderType.Account) {
            OrderInfo storage order = OrderByHash[_hashOrder];
            require(accountAddress[msg.sender] == _target, "CRO4");
            IAccountPlayer(_target).setPause();
            order.target = _target;
            order.amount = 1;
            order.data = _data;
            order.nftId = 0;
            order.paymentToken = _paymentToken;
            order.price = _price;
            order.seller = msg.sender;
        }
        emit CreatedOrder(_target, msg.sender, _hashOrder, _orderType);
    }

    function buyFromOrder(
        bytes32 hashOrder,
        uint256 amount,
        address receiver
    ) public {
        OrderInfo storage order = OrderByHash[hashOrder];
        uint256 amountToPayment = order.price * amount;
        uint256 amountToSeller = calculateFee(amountToPayment);
        if (order.typeOrder == OrderType.ERC721) {
            IERC20Upgradeable(order.paymentToken).transfer(
                receiver,
                amountToSeller
            );
            IERC721(order.target).safeTransferFrom(
                address(this),
                msg.sender,
                order.nftId,
                order.data
            );
        }
    }

    function changeFeePercent(uint256 newPercent)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        fee = newPercent;
    }

    function calculateFee(uint256 bill) public view returns (uint256) {
        uint256 amountFee = (bill / 1000) * fee;
        uint256 sendToSeller = bill - amountFee;
        return sendToSeller;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {}
}
