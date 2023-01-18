//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import "./interface/IFactoryMarket.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
//import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

contract AccountPlayer is
    AccessControlUpgradeable,
    PausableUpgradeable,
    ERC1155HolderUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;
    bool public isBlackListed;
    address private currentOwner;
    address public factory;
    bytes32 public constant FACTORY_ROLE = keccak256("FACTORY_ROLE");

    uint256 public UserID;

    constructor() {
        factory = msg.sender;
    }

    function initialize(address _owner) external {
        require(msg.sender == factory, "Only for factory");
        currentOwner = _owner;
        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(FACTORY_ROLE, msg.sender);
    }

    function currentowner() public view returns (address) {
        return currentOwner;
    }

    function sellItem(
        OrderType _orderType,
        address target,
        address paymentToken,
        bytes32 _hashOrder,
        bytes calldata _data,
        uint256 _price,
        uint256 _nftId,
        uint256 _amount
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(isBlackListed != true, "Blocked");
        if (_orderType == OrderType.ERC721) {
            IERC721Upgradeable(target).approve(factory, _nftId);
        } else if (_orderType == OrderType.ERC1155) {
            IERC1155Upgradeable(target).setApprovalForAll(factory, true);
        }
        IFactoryMarket(factory).createOrder(
            _orderType,
            target,
            paymentToken,
            _hashOrder,
            _data,
            _price,
            _nftId,
            _amount
        );
    }

    receive() external payable {}

    fallback() external payable {}

    function setBlock() external onlyRole(FACTORY_ROLE) {
        isBlackListed = true;
    }

    function grandRoleNewOwner(address _newOwner)
        external
        onlyRole(FACTORY_ROLE)
    {
        revokeRole(DEFAULT_ADMIN_ROLE, currentOwner);
        grantRole(DEFAULT_ADMIN_ROLE, _newOwner);
        currentOwner = _newOwner;
    }

    function setPause(bool _newPauseState) external {
        require(isBlackListed != true, "Blocked");
        require(
            hasRole(FACTORY_ROLE, _msgSender()) ||
                hasRole(DEFAULT_ADMIN_ROLE, _msgSender())
        );
        _newPauseState ? _pause() : _unpause();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155ReceiverUpgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function withdrawNFT(
        address nft,
        address _to,
        uint256 _tokenId
    ) public onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {
        require(isBlackListed != true, "Blocked");
        require(nft != address(0), "Cant trasnfer 0 from empty address");
        IERC721Upgradeable(nft).safeTransferFrom(address(this), _to, _tokenId);
    }

    function witdhrawToken(
        address token,
        address _to,
        uint256 amount
    ) public onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {
        require(isBlackListed != true, "Blocked");
        require(token != address(0), "Cant trasnfer 0 from empty address");
        IERC20Upgradeable(token).transfer(_to, amount);
    }

    function witdhrawCollection(
        address collection,
        address _to,
        uint256 _tokenId,
        uint256 amount,
        bytes calldata _data
    ) public onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {
        require(isBlackListed != true, "Blocked");
        require(collection != address(0), "Cant trasnfer 0 from empty address");
        IERC1155Upgradeable(collection).safeTransferFrom(
            address(this),
            _to,
            _tokenId,
            amount,
            _data
        );
    }
}
