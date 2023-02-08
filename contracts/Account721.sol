//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./interface/IFactoryMarket.sol";
import "./interface/IAccountPlayer.sol";

contract Account721 is
    ERC721("Account", "ACC"),
    ERC1155Holder,
    ERC721Holder,
    Pausable,
    AccessControl
{
    using SafeERC20 for IERC20;
    bool public isBlackListed;
    address public factory;
    address public currentOwner;
    bytes32 public constant FACTORY_ROLE = keccak256("FACTORY_ROLE");

    constructor() {
        factory = msg.sender;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(FACTORY_ROLE, msg.sender);
    }

    receive() external payable {}

    fallback() external payable {}

    function currentowner() public view returns (address) {
        return currentOwner;
    }

    function grandRoleNewOwner(address owner) public onlyRole(FACTORY_ROLE) {
        currentOwner = owner;
    }

    function initialize(address _owner, uint256 userID)
        external
        onlyRole(FACTORY_ROLE)
    {
        _safeMint(_owner, userID);
        currentOwner = _owner;
        grantRole(DEFAULT_ADMIN_ROLE, _owner);
        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
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
            IERC721(target).approve(factory, _nftId);
        } else if (_orderType == OrderType.ERC1155) {
            IERC1155(target).setApprovalForAll(factory, true);
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

    function withdraw721(
        address nft,
        address _to,
        uint256 _tokenId
    ) public onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {
        require(isBlackListed != true, "Blocked");
        require(nft != address(0), "Cant trasnfer 0 from empty address");
        IERC721(nft).safeTransferFrom(address(this), _to, _tokenId);
    }

    function witdhraw20(
        address token,
        address _to,
        uint256 amount
    ) public onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {
        require(isBlackListed != true, "Blocked");
        require(token != address(0), "Cant trasnfer 0 from empty address");
        IERC20(token).transfer(_to, amount);
    }

    function witdhraw1155(
        address collection,
        address _to,
        uint256 _tokenId,
        uint256 amount,
        bytes calldata _data
    ) public onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {
        require(isBlackListed != true, "Blocked");
        require(collection != address(0), "Cant trasnfer 0 from empty address");
        IERC1155(collection).safeTransferFrom(
            address(this),
            _to,
            _tokenId,
            amount,
            _data
        );
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
        override(ERC1155Receiver, ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
