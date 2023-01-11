//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/erc721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/erc721/IERC721.sol";
import "@openzeppelin/contracts/token/erc1155/IERC1155.sol";
import "@openzeppelin/contracts/token/erc20/utils/SafeERC20.sol";

contract AccountPlayer is AccessControl, ERC721Holder {
    using SafeERC20 for IERC20;
    uint256 public UserID;

    constructor(address owner) {}

    receive() external payable {}

    fallback() external payable {
        require(msg.data.length == 0);
    }

    function sellOwnership(address newOwner)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {}

    function withdrawNFT(
        address nft,
        address _to,
        uint256 _tokenId
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        IERC721(nft).safeTransferFrom(address(this), _to, _tokenId);
    }

    function witdhrawToken(
        address token,
        address _to,
        uint256 amount
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        IERC20(token).transfer(_to, amount);
    }

    function witdhrawCollection(
        address collect,
        address _to,
        uint256 _tokenId,
        uint256 amount
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {}
}
