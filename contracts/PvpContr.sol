//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract PvpContr is
    ERC721HolderUpgradeable,
    ERC1155HolderUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    mapping(address => UserRaceParams) public userPositedNFTs;
    struct UserRaceParams {
        address items;
        address[] erc721;
        uint256[] id721;
        uint256[] itemsId;
        uint256[] itemsAmount;
    }
    event Deposited(
        address user,
        address items,
        address[] nft,
        uint256[] id721,
        uint256[] itemsId,
        uint256[] itemsAmount
    );

    function initialize(address owner) public initializer {
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(DEFAULT_ADMIN_ROLE, owner);
        _setupRole(DEFAULT_ADMIN_ROLE, owner);
        __UUPSUpgradeable_init();
    }

    function check(address target) public view returns (UserRaceParams memory) {
        return userPositedNFTs[target];
    }

    function depositItems(bool old, UserRaceParams memory _params) public {
        UserRaceParams storage params = userPositedNFTs[_msgSender()];
        if (old == true) {
            for (uint64 i = 0; i < _params.erc721.length; i++) {
                IERC721Upgradeable(_params.erc721[i]).safeTransferFrom(
                    _msgSender(),
                    address(this),
                    _params.id721[i],
                    ""
                );
            }
        } else {
            IERC721Upgradeable(_params.erc721[0]).safeTransferFrom(
                _msgSender(),
                address(this),
                _params.id721[0],
                ""
            );
        }

        IERC1155Upgradeable(_params.items).safeBatchTransferFrom(
            _msgSender(),
            address(this),
            _params.itemsId,
            _params.itemsAmount,
            ""
        );
        params.erc721 = _params.erc721;
        params.id721 = _params.id721;
        params.items = _params.items;
        params.itemsId = _params.itemsId;
        params.itemsAmount = _params.itemsAmount;
        emit Deposited(
            _msgSender(),
            _params.items,
            _params.erc721,
            _params.id721,
            _params.itemsId,
            _params.itemsAmount
        );
    }

    function setNewBalance(
        UserRaceParams memory params,
        address winner,
        UserRaceParams memory params2,
        address loser
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        UserRaceParams storage parametrs = userPositedNFTs[winner];
        UserRaceParams storage parametrs12 = userPositedNFTs[loser];
        require(params.erc721.length == params.id721.length, "SNQ1");
        require(params2.erc721.length == params2.id721.length, "SNQ2");
        parametrs.erc721 = params.erc721;
        parametrs.id721 = params.id721;
        parametrs.itemsId = params.itemsId;
        parametrs.itemsAmount = params.itemsAmount;
        parametrs12.erc721 = params2.erc721;
        parametrs12.id721 = params2.id721;
        parametrs12.itemsId = params2.itemsId;
        parametrs12.itemsAmount = params2.itemsAmount;
    }

    function withdrawBalance(
        UserRaceParams memory paramsWithd,
        UserRaceParams memory paramsAfter,
        address receiver
    ) public {
        UserRaceParams storage parametrs = userPositedNFTs[_msgSender()];
        require(paramsWithd.erc721.length <= parametrs.erc721.length, "NQ1");
        require(paramsWithd.id721.length <= parametrs.id721.length, "NQ2");
        require(paramsWithd.erc721.length == parametrs.id721.length, "NQ3");
        require(paramsWithd.erc721.length > paramsAfter.id721.length, "NQ4");
        require(paramsWithd.itemsId.length > paramsAfter.itemsId.length, "NQ5");
        for (uint256 i = 0; i < paramsWithd.erc721.length; i++) {
            IERC721Upgradeable(paramsWithd.erc721[i]).safeTransferFrom(
                address(this),
                receiver,
                paramsWithd.id721[i]
            );
        }
        IERC1155Upgradeable(paramsWithd.items).safeBatchTransferFrom(
            address(this),
            receiver,
            paramsWithd.itemsId,
            paramsWithd.itemsAmount,
            ""
        );
        parametrs.erc721 = paramsAfter.erc721;
        parametrs.id721 = paramsAfter.id721;
        parametrs.itemsId = paramsAfter.itemsId;
        parametrs.itemsAmount = paramsAfter.itemsAmount;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControlUpgradeable, ERC1155ReceiverUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {}
}
