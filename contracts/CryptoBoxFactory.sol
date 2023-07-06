//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "./interface/PartsLibrary.sol";
import "./interface/ICryptoBoxFactory.sol";
import "./interface/IItems.sol";

contract CryptoBoxFactory is ReentrancyGuard, AccessControl, VRFConsumerBaseV2 {
    using SafeERC20 for IERC20;

    mapping(uint => address) public cryptoBoxByIndex;
    mapping(address => bool) public cryptoBoxExists;

    address public Items;
    address public MTCB;
    address public LinkToken;
    bytes32 public keyHash;
    uint16 requestConfirmations = 3;
    uint32 numWords;
    uint32 callbackGasLimit = 100000;
    uint64 subscriptionId;
    VRFCoordinatorV2Interface public COORDINATOR;

    constructor()
        VRFConsumerBaseV2(0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625)
    {
        COORDINATOR = VRFCoordinatorV2Interface(
            0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625
        );
        callbackGasLimit = 300000;
        numWords = 12;
        keyHash = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
        requestConfirmations = 3;
        subscriptionId = 2148;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function addCryptoBox(
        uint index,
        address cryptoBox
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        cryptoBoxByIndex[index] = cryptoBox;
        cryptoBoxExists[cryptoBox] = true;
    }

    function createNewSubscription() private onlyRole(DEFAULT_ADMIN_ROLE) {
        subscriptionId = VRFCoordinatorV2Interface(COORDINATOR)
            .createSubscription();
        VRFCoordinatorV2Interface(COORDINATOR).addConsumer(
            subscriptionId,
            address(this)
        );
    }

    //save msg.sender
    // Assumes the subscription is funded sufficiently.
    function requestRandomWords(
        uint boxIndex
    ) external onlyRole(DEFAULT_ADMIN_ROLE) returns (uint256 requestId) {
        // Will revert if subscription is not set and funded.
        requestId = VRFCoordinatorV2Interface(COORDINATOR).requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        // require(s_requests[_requestId].exists, "request not found");
        // s_requests[_requestId].fulfilled = true;
        // s_requests[_requestId].randomWords = _randomWords;
        //emit RequestFulfilled(_requestId, _randomWords);
    }

    function getRequestStatus(
        uint256 _requestId
    ) external view returns (bool fulfilled, uint256[] memory randomWords) {
        // require(s_requests[_requestId].exists, "request not found");
        // RequestStatus memory request = s_requests[_requestId];
        //return (request.fulfilled, request.randomWords);
    }

    function transferMTCB(uint amount, address to) public {
        IERC20(MTCB).transfer(to, amount);
    }

    function mintItems(uint id, address to) public {
        IItems(Items).mint(id, 0, to);
    }
}
