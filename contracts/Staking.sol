//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract Staking is
    AccessControlUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    struct UserInfo {
        uint amount;
        uint timeStart;
    }

    struct PoolInfo {
        uint rank;
        uint lowerValue;
        uint higherValue;
        uint procentPerDay;
    }
    // PoolInfo[] public poolsInfo;

    IERC20Upgradeable public token;
    // uint public totalAllocPoint = 0;
    mapping(uint => PoolInfo) public poolInfo;
    mapping(uint => mapping(address => UserInfo)) public usersInfo;

    event Deposit(
        address indexed user,
        uint indexed pid,
        uint amount,
        uint time
    );
    event Withdraw(address indexed user, uint indexed pid, uint amount);

    function initialize(address owner) public initializer {
        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(DEFAULT_ADMIN_ROLE, owner);
        __UUPSUpgradeable_init();
    }

    function addStrategy(
        uint _rank,
        uint _lowerValue,
        uint _higherValue,
        uint _procentPerDay
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {}

    function set(
        uint _pid,
        uint _rank,
        uint _procentPerDay,
        uint _lowerValue,
        uint _higherValue
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        PoolInfo storage pool = poolInfo[_pid];
        pool.procentPerDay = _procentPerDay;
        pool.rank = _rank;
        pool.lowerValue = _lowerValue;
        pool.higherValue = _higherValue;
    }

    function startStake(uint _pid, uint _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = usersInfo[_pid][msg.sender];
        require(_amount >= pool.lowerValue && _amount <= pool.higherValue);
        user.amount = user.amount + _amount;
        user.timeStart = block.timestamp;
        emit Deposit(msg.sender, _pid, _amount, user.timeStart);
    }

    function unstake(uint _pid) public nonReentrant {
        UserInfo storage user = usersInfo[_pid][msg.sender];
        //uint reward = calculateReward(_pid, msg.sender);
        user.timeStart = block.timestamp;
        user.amount = 0;
        //transfer(address(msg.sender), reward);
    }

    function calculateReward(
        uint startStake,
        uint pool
    ) internal returns (uint) {}

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}
}
