//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Tournament is Ownable, IERC721Receiver {
    using SafeMath for uint256;
    IERC721 public nft;
    IERC20 public busd;

    event Ticket(
        uint256 _idBike,
        uint256 _price,
        uint256 _ticketType,
        address _from,
        uint256 _jackpotAmount,
        uint256 _ownerAmount
    );
    event TicketBusd(
        uint256 _idBike,
        uint256 _price,
        uint256 _ticketType,
        address _from,
        uint256 _jackpotAmount,
        uint256 _ownerAmount
    );

    address public ownerAddress;
    address public jackpotAddress;

    uint256 public feeAmount;
    uint256 public feeBusdAmount;
    uint256 public rateBusdBnb;

    mapping(uint256 => uint256) public prices;
    mapping(uint256 => mapping(address => uint256)) public bikes;

    bool public isBnbPaymentPossible;
    bool public isBusdPaymentPossible;

    constructor(
        address _owner,
        address _jackpot,
        uint256 _feeAmount,
        uint256 _feeBusdAmount,
        IERC721 _nft,
        IERC20 _busd
    ) {
        ownerAddress = _owner;
        jackpotAddress = _jackpot;
        nft = _nft;
        busd = _busd;
        feeAmount = _feeAmount;
        feeBusdAmount = _feeBusdAmount;
        isBnbPaymentPossible = true;
        isBusdPaymentPossible = false;
    }

    function buyTicket(uint256 _idBike, uint256 _ticketType) public payable {
        require(isBnbPaymentPossible, "Payment method not available");
        require(
            getBnbPrice(_ticketType) == msg.value,
            "Wrong amount of BNB sent"
        );
        require(
            bikes[_ticketType][msg.sender] == 0,
            "You already have this ticket"
        );

        uint256 amountToDivide = msg.value - feeAmount;
        uint256 jackpotAmount = (amountToDivide * 60) / 100;
        uint256 ownerAmount = (amountToDivide * 40) / 100;
        jackpotAmount = jackpotAmount + feeAmount;

        payable(jackpotAddress).transfer(jackpotAmount);
        payable(ownerAddress).transfer(ownerAmount);

        nft.safeTransferFrom(msg.sender, address(this), _idBike);

        bikes[_ticketType][msg.sender] = _idBike;

        emit Ticket(
            _idBike,
            msg.value,
            _ticketType,
            msg.sender,
            jackpotAmount,
            ownerAmount
        );
    }

    function buyTicketForBusd(
        uint256 _idBike,
        uint256 _ticketType,
        uint256 _amount
    ) public {
        require(isBusdPaymentPossible, "Payment method not available");
        require(
            getBusdPrice(_ticketType) == _amount,
            "Wrong amount of BUSD sent"
        );
        require(
            bikes[_ticketType][msg.sender] == 0,
            "You already have this ticket"
        );

        uint256 amountToDivide = _amount - feeBusdAmount;
        uint256 jackpotAmount = (amountToDivide * 60) / 100;
        uint256 ownerAmount = (amountToDivide * 40) / 100;
        jackpotAmount = jackpotAmount + feeBusdAmount;

        busd.transferFrom(msg.sender, jackpotAddress, jackpotAmount);
        busd.transferFrom(msg.sender, ownerAddress, ownerAmount);

        nft.safeTransferFrom(msg.sender, address(this), _idBike);

        bikes[_ticketType][msg.sender] = _idBike;

        emit TicketBusd(
            _idBike,
            _amount,
            _ticketType,
            msg.sender,
            jackpotAmount,
            ownerAmount
        );
    }

    function setPrices(uint256[] memory _array) public onlyOwner {
        for (uint256 i = 0; i < _array.length; i++) {
            prices[i + 1] = _array[i];
        }
    }

    function returnBike(uint256 _ticketType, address _userAddress)
        public
        onlyOwner
    {
        require(bikes[_ticketType][_userAddress] != 0, "Wrong id bike");
        nft.safeTransferFrom(
            address(this),
            _userAddress,
            bikes[_ticketType][_userAddress]
        );
        bikes[_ticketType][_userAddress] = 0;
    }

    function getBnbPrice(uint256 _ticketType) public returns (uint256) {
        return prices[_ticketType] * rateBusdBnb;
    }

    function getBusdPrice(uint256 _ticketType) public returns (uint256) {
        return prices[_ticketType] * 1 ether;
    }

    function setFeeAmount(uint256 _amount) public onlyOwner {
        feeAmount = _amount;
    }

    function setFeeBusdAmount(uint256 _amount) public onlyOwner {
        feeBusdAmount = _amount;
    }

    function setOwnerAddress(address _newOwner) public onlyOwner {
        ownerAddress = _newOwner;
    }

    function setJackpotAddress(address _newAddress) public onlyOwner {
        jackpotAddress = _newAddress;
    }

    function setNftAddress(IERC721 _nft) public onlyOwner {
        nft = _nft;
    }

    function setIsBnbPaymentPossible(bool _val) public onlyOwner {
        isBnbPaymentPossible = _val;
    }

    function setIsBusdPaymentPossible(bool _val) public onlyOwner {
        isBusdPaymentPossible = _val;
    }

    function setBusdBnbRate(uint256 _rate) public onlyOwner {
        rateBusdBnb = _rate;
    }

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes memory _data
    ) public override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
