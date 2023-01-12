//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./IAccountPlayer.sol";

contract AccountPlayer is AccessControl, ERC721Holder, Pausable {
    using SafeERC20 for IERC20;
    uint256 public UserID;
    address public currentOwner;
    bool public isBlackListed;
    bytes32 public constant FACTORY_ROLE = keccak256("FACTORY_ROLE");

    constructor(
        address owner,
        address factory,
        uint256 idAccount
    ) {
        grantRole(FACTORY_ROLE, factory);
        grantRole(DEFAULT_ADMIN_ROLE, owner);
        UserID = idAccount;
    }

    receive() external payable {}

    fallback() external payable {
        require(msg.data.length == 0);
    }

    function setBlock() external onlyRole(FACTORY_ROLE) {
        isBlackListed = true;
    }

    function setPause(bool _newPauseState) external {
        require(
            hasRole(FACTORY_ROLE, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender)
        );
        _newPauseState ? _pause() : _unpause();
    }

    function sellOwnership(address newOwner)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        revokeRole(DEFAULT_ADMIN_ROLE, currentOwner);
        grantRole(DEFAULT_ADMIN_ROLE, newOwner);
        currentOwner = newOwner;
    }

    function withdrawNFT(
        address nft,
        address _to,
        uint256 _tokenId
    ) public onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {
        IERC721(nft).safeTransferFrom(address(this), _to, _tokenId);
    }

    function witdhrawToken(
        address token,
        address _to,
        uint256 amount
    ) public onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {
        IERC20(token).transfer(_to, amount);
    }

    function witdhrawCollection(
        address collection,
        address _to,
        uint256 _tokenId,
        uint256 amount,
        bytes calldata _data
    ) public onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {
        require(
            IERC1155(collection).balanceOf(address(this), _tokenId) >= amount
        );
        IERC1155(collection).safeTransferFrom(
            address(this),
            _to,
            _tokenId,
            amount,
            _data
        );
    }
}
