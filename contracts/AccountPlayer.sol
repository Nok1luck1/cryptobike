//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
//import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

contract AccountPlayer is AccessControlUpgradeable, PausableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    bool public isBlackListed;
    address private currentOwner;
    bytes32 public constant FACTORY_ROLE = keccak256("FACTORY_ROLE");
    address public factory;
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
        require(
            hasRole(FACTORY_ROLE, _msgSender()) ||
                hasRole(DEFAULT_ADMIN_ROLE, _msgSender())
        );
        _newPauseState ? _pause() : _unpause();
    }

    function withdrawNFT(
        address nft,
        address _to,
        uint256 _tokenId
    ) public onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {
        require(nft != address(0), "Cant trasnfer 0 from empty address");
        IERC721Upgradeable(nft).safeTransferFrom(address(this), _to, _tokenId);
    }

    function witdhrawToken(
        address token,
        address _to,
        uint256 amount
    ) public onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {
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
