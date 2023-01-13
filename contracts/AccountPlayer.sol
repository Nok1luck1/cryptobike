//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
//import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/Pausableupgradeable.sol";
import "./interface/IAccountPlayer.sol";

contract AccountPlayer is AccessControlUpgradeable, PausableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    uint256 public UserID;
    address public currentOwner;
    bool public isBlackListed;
    bytes32 public constant FACTORY_ROLE = keccak256("FACTORY_ROLE");

    constructor(address owner, uint256 idAccount) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        //grantRole(FACTORY_ROLE, _msgSender());
        //grantRole(DEFAULT_ADMIN_ROLE, owner);
        currentOwner = owner;
        UserID = idAccount;
    }

    receive() external payable {}

    fallback() external payable {
        require(msg.data.length == 0);
    }

    function setBlock() external onlyRole(FACTORY_ROLE) {
        isBlackListed = true;
    }

    function grandRoleNewOwner(address newOwner)
        external
        onlyRole(FACTORY_ROLE)
    {
        revokeRole(DEFAULT_ADMIN_ROLE, currentOwner);
        grantRole(DEFAULT_ADMIN_ROLE, newOwner);
        currentOwner = newOwner;
    }

    function setPause(bool _newPauseState) external {
        require(
            hasRole(FACTORY_ROLE, _msgSender()) ||
                hasRole(DEFAULT_ADMIN_ROLE, _msgSender())
        );
        _newPauseState ? _pause() : _unpause();
    }

    function sellOwnership(address newOwner) public onlyRole(FACTORY_ROLE) {
        revokeRole(DEFAULT_ADMIN_ROLE, currentOwner);
        grantRole(DEFAULT_ADMIN_ROLE, newOwner);
        currentOwner = newOwner;
    }

    // function withdrawNFT(
    //     address nft,
    //     address _to,
    //     uint256 _tokenId
    // ) public onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {
    //     IERC721(nft).safeTransferFrom(address(this), _to, _tokenId);
    // }

    // function witdhrawToken(
    //     address token,
    //     address _to,
    //     uint256 amount
    // ) public onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {
    //     IERC20(token).transfer(_to, amount);
    // }

    // function witdhrawCollection(
    //     address collection,
    //     address _to,
    //     uint256 _tokenId,
    //     uint256 amount,
    //     bytes calldata _data
    // ) public onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {
    //     require(
    //         IERC1155(collection).balanceOf(address(this), _tokenId) >= amount
    //     );
    //     IERC1155(collection).safeTransferFrom(
    //         address(this),
    //         _to,
    //         _tokenId,
    //         amount,
    //         _data
    //     );
    // }
}
