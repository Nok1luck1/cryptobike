//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import "./AccountPlayer.sol";
import "./interface/IAccountPlayer.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";

contract FactoryMarket is
    Initializable,
    UUPSUpgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    ERC1155HolderUpgradeable
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
    mapping(address => bool) public blockedAccount;
    event CreatedAccount(
        address User,
        address generatedAccount,
        uint256 accountId
    );
    event CreatedOrder(
        address target,
        address creator,
        bytes32 hashOrder,
        OrderType typeOrder
    );
    event CancelOrder(
        address target,
        address canceler,
        bytes32 hashOrder,
        OrderType typeOrder
    );
    event BuyInOrder(
        address target,
        address buyer,
        bytes32 hashOrder,
        OrderType typeOrder
    );
    event BlockedAccount(address owner, address account);
    event PaymentSended(
        address seller,
        address buyer,
        address target,
        uint256 amountToSeller
    );
    event Withdraw(address withdrawer, address token, uint256 amount);

    function initialize(address owner) public initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        grantRole(DEFAULT_ADMIN_ROLE, owner);
        fee = 30;
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();
    }

    function generateAccount(uint256 accountId) public returns (address) {
        address createdAccount;
        require(
            accountAddress[_msgSender()] == address(0),
            "You cant Create more accounts"
        );
        bytes memory bytecodeAccount = type(AccountPlayer).creationCode;
        require(
            bytecodeAccount.length != 0,
            "Create2: bytecode length is zero"
        );
        bytes32 salt = keccak256(abi.encodePacked(_msgSender(), accountId));
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
        require(
            createdAccount != address(0),
            "Create2: Failed to create Account"
        );
        IAccountPlayer(createdAccount).initialize(_msgSender());
        accountAddress[_msgSender()] = createdAccount;
        emit CreatedAccount(_msgSender(), createdAccount, accountId);
        return createdAccount;
    }

    function blockAccount(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        IAccountPlayer(account).setBlock(true);
        address owner = accountAddress[account];
        blockedAccount[account] = true;
        emit BlockedAccount(owner, account);
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
        } else if (_orderType == OrderType.ERC1155) {
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
        } else if (_orderType == OrderType.Account) {
            OrderInfo storage order = OrderByHash[_hashOrder];
            require(
                accountAddress[msg.sender] == _target,
                "Cant sell foreign account"
            );
            require(blockedAccount[_target] != true, "Blocked account");
            require(
                IAccountPlayer(_target).currentowner() == _msgSender(),
                "CANAEFVAE"
            );
            IAccountPlayer(_target).setPause(true);
            order.target = _target;
            order.typeOrder = _orderType;
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
        uint256 _amount,
        address receiver
    ) public payable {
        OrderInfo storage _order = OrderByHash[hashOrder];
        uint256 amountToPayment = _order.price * _amount;
        uint256 amountToSeller = calculateFee(amountToPayment);
        //send payment to seller
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
        if (_order.typeOrder == OrderType.ERC721) {
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
        } else if (_order.typeOrder == OrderType.ERC1155) {
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
        } else if (_order.typeOrder == OrderType.Account) {
            require(blockedAccount[_order.target] != true, "Blocked account");
            require(
                accountAddress[_msgSender()] == address(0),
                "You cant have more accounts"
            );
            IAccountPlayer(_order.target).grandRoleNewOwner(_msgSender());
            delete accountAddress[_order.seller];
            accountAddress[_msgSender()] = _order.target;
            IAccountPlayer(_order.target).setPause(false);
            emit BuyInOrder(
                _order.target,
                receiver,
                hashOrder,
                _order.typeOrder
            );
            delete OrderByHash[hashOrder];
        }
    }

    function cancelOrder(bytes32 hashOrder, address receiveTarget) public {
        OrderInfo storage order = OrderByHash[hashOrder];
        require(msg.sender == order.seller);
        if (order.typeOrder == OrderType.ERC721) {
            IERC721Upgradeable(order.target).safeTransferFrom(
                address(this),
                receiveTarget,
                order.nftId,
                order.data
            );
        } else if (order.typeOrder == OrderType.ERC1155) {
            IERC1155Upgradeable(order.target).safeTransferFrom(
                address(this),
                receiveTarget,
                order.nftId,
                order.amount,
                order.data
            );
        } else if (order.typeOrder == OrderType.Account) {
            IAccountPlayer(order.target).setPause(false);
        }
        emit CancelOrder(order.target, msg.sender, hashOrder, order.typeOrder);
        delete OrderByHash[hashOrder];
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

    function withdrawFee(address _token, uint256 _amount)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (uint256)
    {
        IERC20Upgradeable(_token).transfer(address(msg.sender), _amount);
        emit Withdraw(address(msg.sender), _token, _amount);
        return _amount;
    }

    function widtrawValue(uint256 _amount) public onlyRole(DEFAULT_ADMIN_ROLE) {
        AddressUpgradeable.sendValue(payable(_msgSender()), _amount);
    }

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes memory _data
    ) public pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155ReceiverUpgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {}
}
