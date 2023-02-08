// //SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.0;
// import "./interface/IFactoryMarket.sol";
// import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165CheckerUpgradeable.sol";

// contract AccountNFT is
//     AccessControlUpgradeable,
//     PausableUpgradeable,
//     ERC1155Upgradeable,
//     ERC721HolderUpgradeable
// {
//     using SafeERC20Upgradeable for IERC20Upgradeable;
//     bool public isBlackListed;
//     address private currentOwner;
    

//     uint256 public UserID;

//     constructor(address _factory) {
//         _setupRole(DEFAULT_ADMIN_ROLE, _factory);
//         _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
//         _setupRole(FACTORY_ROLE, _factory);
//     }

   

//     function balanceOf(address token, uint256 id)
//         public
//         view
//         override
//         returns (uint256 balance)
//     {
//         uint256 typeToken = checkVersion(token);
//         if (typeToken == 0) {
//             balance = IERC721Upgradeable(token).balanceOf(address(this));
//             return balance;
//         } else if (typeToken == 1) {
//             balance = IERC1155Upgradeable(token).balanceOf(address(this), id);
//             return balance;
//         }
//     }

//     function mint(address owner, uint256 _id) public onlyRole(FACTORY_ROLE) {
//         _mint(owner, _id, 1, "");
//     }

//     function checkVersion(address target) public view returns (uint256) {
//         if (
//             ERC165CheckerUpgradeable.supportsInterface(
//                 target,
//                 type(IERC721Upgradeable).interfaceId
//             )
//         ) {
//             return 0;
//         } else if (
//             ERC165CheckerUpgradeable.supportsInterface(
//                 target,
//                 type(IERC1155Upgradeable).interfaceId
//             )
//         ) {
//             return 1;
//         }
//     }

//     function sellItem(
//         OrderType _orderType,
//         address target,
//         address paymentToken,
//         bytes32 _hashOrder,
//         bytes calldata _data,
//         uint256 _price,
//         uint256 _nftId,
//         uint256 _amount
//     ) public onlyRole(DEFAULT_ADMIN_ROLE) {
//         require(isBlackListed != true, "Blocked");
//         if (_orderType == OrderType.ERC721) {
//             IERC721Upgradeable(target).approve(factory, _nftId);
//         } else if (_orderType == OrderType.ERC1155) {
//             IERC1155Upgradeable(target).setApprovalForAll(factory, true);
//         }
//         IFactoryMarket(factory).createOrder(
//             _orderType,
//             target,
//             paymentToken,
//             _hashOrder,
//             _data,
//             _price,
//             _nftId,
//             _amount
//         );
//     }

    

//     function setBlock() external onlyRole(FACTORY_ROLE) {
//         isBlackListed = true;
//     }

//     function grandRoleNewOwner(address _newOwner)
//         external
//         onlyRole(FACTORY_ROLE)
//     {
//         revokeRole(DEFAULT_ADMIN_ROLE, currentOwner);
//         grantRole(DEFAULT_ADMIN_ROLE, _newOwner);
//         currentOwner = _newOwner;
//     }

   

//     function supportsInterface(bytes4 interfaceId)
//         public
//         view
//         override(ERC1155Upgradeable, AccessControlUpgradeable)
//         returns (bool)
//     {
//         return super.supportsInterface(interfaceId);
//     }

    
// }
