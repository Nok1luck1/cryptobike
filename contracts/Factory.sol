//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./Account721.sol";
import "./interface/IFactoryMarket.sol";
import "./interface/IAccountPlayer.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Factory is
    AccessControl,
    Pausable,
    ERC1155Holder,
    ERC721Holder,
    ReentrancyGuard
{
    using SafeERC20 for IERC20;
    address public market;
    uint64 public fee; //1% = 10

    mapping(address => address) public accountAddress;
    mapping(bytes32 => OrderAccount) public orderAccounts;

    struct OrderAccount {
        address target;
        address seller;
        address paymentT;
        uint64 accountID;
        uint128 price;
        address[] addr721;
        address[] addr1155;
        uint64[] tokens721;
        uint64[] tokens1155;
        uint64[] amounts;
    }
    struct CreationParams {
        address erc1155;
        uint256 accountId;
        address[] addrERC721;
        uint64[] id721;
        uint256[] ids;
        uint256[] amounts;
    }
    event CreatedAccount(
        address User,
        address generatedAccount,
        uint256 accountId
    );
    event PaymentSended(
        address seller,
        address buyer,
        address target,
        uint256 amountToSeller
    );
    event OrderSellAccount(
        address target,
        address seller,
        address[] addr721,
        address[] addr1155,
        uint64[] tokens721,
        uint64[] tokens1155,
        uint256 price
    );

    constructor(address _market, uint64 _fee) {
        market = _market;
        fee = _fee;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    receive() external payable {}

    fallback() external payable {}

    function userHasAccount(address _user) public view returns (address) {
        return accountAddress[_user];
    }

    function changeFeePercent(
        uint64 newPercent
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        fee = newPercent;
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
        IERC20(_token).transfer(address(_msgSender()), _amount);
        return _amount;
    }

    function widtrawValue(uint256 _amount) public onlyRole(DEFAULT_ADMIN_ROLE) {
        Address.sendValue(payable(_msgSender()), _amount);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC1155Receiver, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function generateAccount(
        CreationParams calldata params
    ) public returns (address) {
        address createdAccount;
        require(
            accountAddress[_msgSender()] == address(0),
            "You cant Create more accounts"
        );
        bytes memory bytecodeAccount = type(Account721).creationCode;
        require(
            bytecodeAccount.length != 0,
            "Create2: bytecode length is zero"
        );
        bytes32 salt = keccak256(
            abi.encodePacked(_msgSender(), params.accountId)
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
        require(
            createdAccount != address(0),
            "Create2: Failed to create Account"
        );
        IAccountPlayer(createdAccount).initialize(
            _msgSender(),
            market,
            params.accountId
        );
        accountAddress[_msgSender()] = createdAccount;
        for (uint256 i = 0; i < params.id721.length; i++) {
            IERC721(params.addrERC721[i]).safeTransferFrom(
                _msgSender(),
                address(this),
                params.id721[i],
                ""
            );
            IERC721(params.addrERC721[i]).safeTransferFrom(
                address(this),
                createdAccount,
                params.id721[i],
                ""
            );
        }
        if (params.erc1155 != address(0)) {
            IERC1155(params.erc1155).safeBatchTransferFrom(
                _msgSender(),
                address(this),
                params.ids,
                params.amounts,
                ""
            );
            IERC1155(params.erc1155).safeBatchTransferFrom(
                address(this),
                createdAccount,
                params.ids,
                params.amounts,
                ""
            );
        }

        emit CreatedAccount(_msgSender(), createdAccount, params.accountId);
        return createdAccount;
    }

    function sellAcc(OrderAccount memory _params, bytes32 hashOrd) public {
        require(_params.target != address(0), "empty addr");
        OrderAccount storage order = orderAccounts[hashOrd];
        order.seller = msg.sender;
        order.paymentT = _params.paymentT;
        order.price = _params.price;
        order.accountID = _params.accountID;
        order.target = _params.target;
        order.addr721 = _params.addr721;
        order.tokens721 = _params.tokens721;
        order.addr1155 = _params.addr1155;
        order.tokens1155 = _params.tokens1155;
        order.amounts = _params.amounts;
        IERC721(order.target).safeTransferFrom(
            msg.sender,
            address(this),
            _params.accountID,
            ""
        );
        emit OrderSellAccount(
            _params.target,
            msg.sender,
            _params.addr721,
            _params.addr1155,
            _params.tokens721,
            _params.tokens1155,
            _params.price
        );
    }

    function buyAcc(bytes32 hashOrd, address receiver) public nonReentrant {
        OrderAccount storage order = orderAccounts[hashOrd];
        uint256 paymentToSeller = calculateFee(order.price);
        if (order.paymentT == address(0)) {} else {
            IERC20(order.paymentT).transferFrom(
                msg.sender,
                address(this),
                order.price
            );
            IERC20(order.paymentT).transfer(order.seller, paymentToSeller);
        }

        if (accountAddress[msg.sender] == address(0)) {
            IERC721(order.target).safeTransferFrom(
                address(this),
                msg.sender,
                order.accountID,
                ""
            );
            accountAddress[msg.sender] = order.target;
        } else {
            for (uint64 i = 0; i < order.addr721.length; i++) {
                IAccountPlayer(order.target).withdraw721(
                    order.addr721[i],
                    receiver,
                    order.tokens721[i]
                );
            }
            for (uint64 i = 0; i < order.addr1155.length; i++) {
                IAccountPlayer(order.target).witdhraw1155(
                    order.addr1155[i],
                    receiver,
                    order.tokens1155[i],
                    order.amounts[i],
                    ""
                );
            }
        }
    }
}
