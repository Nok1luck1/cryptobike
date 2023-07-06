//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";

contract Vesting is
    ReentrancyGuardUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;
    struct VestingSchedule {
        address beneficiary;
        uint8 claimedPeriods;
        uint8 totalPeriods;
        uint256 periodDuration;
        uint256 startTime;
        uint256 amountTotal;
        uint256 released;
    }
    uint private totalLocked;

    IERC20Upgradeable private _token;
    mapping(address => uint[]) public userVestings;
    mapping(bytes32 => VestingSchedule) public vestingSchedules;

    function initialize(
        address owner,
        IERC20Upgradeable token
    ) public initializer {
        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(DEFAULT_ADMIN_ROLE, owner);
        __UUPSUpgradeable_init();
        _token = token;
    }

    function createVestingSchedule(
        bytes32 pointer,
        VestingSchedule memory vest
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(vest.startTime > 0, "TokenVesting: duration must be > 0");
        require(vest.amountTotal > 0, "TokenVesting: amount must be > 0");
        require(vest.totalPeriods >= 1, "TokenVesting: Period must be >= 1");
        VestingSchedule storage vesting = vestingSchedules[pointer];
        vesting.beneficiary = vest.beneficiary;
        vesting.claimedPeriods = 0;
        vesting.startTime = vest.startTime;
        vesting.periodDuration = vest.periodDuration;
        vesting.totalPeriods = vest.totalPeriods;
        vesting.amountTotal = vest.amountTotal;
        vesting.released = 0;
    }

    function multiCreate(
        bytes32[] calldata pointers,
        VestingSchedule[] memory vestings
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(pointers.length == vestings.length, "mismatch arrays length");
        for (uint i = 0; i <= pointers.length; i++) {
            createVestingSchedule(pointers[i], vestings[i]);
        }
    }

    function time() public view returns (uint) {
        return block.timestamp + 2000;
    }

    function claim(bytes32 pointer) public nonReentrant {
        VestingSchedule storage vesting = vestingSchedules[pointer];
        require(_msgSender() == vesting.beneficiary, "Not for you");
        uint amount = calculateAmount(pointer);
        IERC20Upgradeable(_token).transfer(_msgSender(), amount);
        vesting.released = vesting.released + amount;
        if (vesting.released == vesting.amountTotal) {
            delete vestingSchedules[pointer];
        }
    }

    function withdraw(
        uint256 amount
    ) external nonReentrant onlyRole(DEFAULT_ADMIN_ROLE) {
        require(
            IERC20Upgradeable(_token).balanceOf(address(this)) >= amount,
            "TokenVesting: not enough withdrawable funds"
        );
        IERC20Upgradeable(_token).safeTransfer(msg.sender, amount);
    }

    function calculateAmount(
        bytes32 vestingPointer
    ) internal returns (uint amount) {
        VestingSchedule storage vesting = vestingSchedules[vestingPointer];
        uint amountPerPeriod = vesting.totalPeriods / vesting.amountTotal;
        uint timeEnding = vesting.startTime +
            (vesting.periodDuration * vesting.totalPeriods);
        uint left = (block.timestamp - vesting.startTime);
        uint currentTimeline = MathUpgradeable.ceilDiv(
            left,
            vesting.periodDuration
        );
        if (block.timestamp > timeEnding) {
            amount = vesting.amountTotal - vesting.released;
            return amount;
        } else if (currentTimeline - vesting.claimedPeriods == 0) {
            amount = 0;
            return amount;
        } else if (timeEnding > block.timestamp) {
            amount =
                (currentTimeline - vesting.claimedPeriods) *
                amountPerPeriod;
            vesting.claimedPeriods = uint8(currentTimeline);
            return amount;
        }
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}
}
