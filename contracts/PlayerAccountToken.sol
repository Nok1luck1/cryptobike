pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/erc1155/ERC1155.sol";
//import "@openzeppelin/contracts/token/erc721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/erc721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/erc721/IERC721.sol";

contract PlayerAccountToken is ERC1155, ERC721Holder, AccessControl {
    function transferERC721(
        address nft,
        address to,
        uint256 tokenID,
        bytes calldata _data
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        IERC721(nft).safeTransferFrom(address(this), to, tokenID, _data);
    }
}
