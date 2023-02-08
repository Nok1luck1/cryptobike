//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./Account721.sol";
import "./interface/IAccountPlayer.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract FactoryMarketNonProx is
    AccessControl,
    Pausable,
    ERC1155Holder,
    ERC721Holder
{
    using SafeERC20 for IERC20;

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

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        fee = 30;
    }

    function generateAccount(
        uint256 accountId,
        uint256[] calldata id721,
        address[] calldata addrERC721
    ) public returns (address) {
        address createdAccount;
        require(
            userHasAccount(_msgSender()) == address(0),
            "You cant Create more accounts"
        );
        bytes memory bytecodeAccount = type(Account721).creationCode;
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
        IAccountPlayer(createdAccount).initialize(_msgSender(), accountId);
        accountAddress[_msgSender()] = createdAccount;
        for (uint256 i = 0; i < id721.length; i++) {
            IERC721(addrERC721[i]).safeTransferFrom(
                _msgSender(),
                address(this),
                id721[i],
                ""
            );
            IERC721(addrERC721[i]).safeTransferFrom(
                address(this),
                createdAccount,
                id721[i],
                ""
            );
        }
        emit CreatedAccount(_msgSender(), createdAccount, accountId);
        return createdAccount;
    }

    function blockAccount(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        IAccountPlayer(account).setBlock(true);
        address owner = accountAddress[account];
        blockedAccount[account] = true;
        emit BlockedAccount(owner, account);
    }

    function userHasAccount(address _user) public view returns (address) {
        return accountAddress[_user];
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
            order.typeOrder = _orderType;
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
    ) public payable {
        OrderInfo storage _order = OrderByHash[hashOrder];
        uint256 amountToPayment = _order.price * _amount;
        uint256 amountToSeller = calculateFee(amountToPayment);
        if (_order.paymentToken == address(0)) {
            Address.sendValue(payable(_order.seller), amountToSeller);
        } else {
            IERC20(_order.paymentToken).safeTransferFrom(
                _msgSender(),
                address(this),
                _order.price
            );
            IERC20(_order.paymentToken).safeTransfer(
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
            if (checkAccount(_order.target) == true) {
                IAccountPlayer(_order.target).grandRoleNewOwner(_msgSender());
            }
            IERC721(_order.target).safeTransferFrom(
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
            IERC1155(_order.target).safeTransferFrom(
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

    function checkAccount(address target) internal returns (bool) {
        (bool success, ) = target.call(abi.encodeWithSignature("currentowner"));
        return success;
    }

    function cancelOrder(bytes32 hashOrder, address receiveTarget) public {
        OrderInfo storage order = OrderByHash[hashOrder];
        require(msg.sender == order.seller);
        if (order.typeOrder == OrderType.ERC721) {
            IERC721(order.target).safeTransferFrom(
                address(this),
                receiveTarget,
                order.nftId,
                order.data
            );
        } else if (order.typeOrder == OrderType.ERC1155) {
            IERC1155(order.target).safeTransferFrom(
                address(this),
                receiveTarget,
                order.nftId,
                order.amount,
                order.data
            );
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
        IERC20(_token).transfer(address(msg.sender), _amount);
        emit Withdraw(address(msg.sender), _token, _amount);
        return _amount;
    }

    function widtrawValue(uint256 _amount) public onlyRole(DEFAULT_ADMIN_ROLE) {
        Address.sendValue(payable(_msgSender()), _amount);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155Receiver, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
