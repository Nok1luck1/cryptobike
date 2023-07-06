//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./interface/IMarket.sol";
import "./interface/IAccountPlayer.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract Account721 is
    ERC721("Account", "ACC"),
    ERC1155Holder,
    ERC721Holder,
    AccessControl
{
    address public market;
    address public currentOwner;
    bytes32 public constant FACTORY_ROLE = keccak256("FACTORY_ROLE");
    event NewOwner(address oldOwner, address newOwner);

    constructor() {
        _setupRole(FACTORY_ROLE, msg.sender);
    }

    receive() external payable {}

    fallback() external payable {}

    function currentowner() public view returns (address) {
        return currentOwner;
    }

    function grandRoleNewOwner(address owner) internal {
        require(
            hasRole(FACTORY_ROLE, _msgSender()) ||
                hasRole(DEFAULT_ADMIN_ROLE, _msgSender())
        );
        _grantRole(DEFAULT_ADMIN_ROLE, owner);
        _revokeRole(DEFAULT_ADMIN_ROLE, currentOwner);
        emit NewOwner(currentOwner, owner);
        currentOwner = owner;
    }

    function initialize(
        address _owner,
        address _market,
        uint256 userID
    ) external onlyRole(FACTORY_ROLE) {
        _safeMint(_owner, userID);
        currentOwner = _owner;
        market = _market;
        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        grandRoleNewOwner(to);
        _safeTransfer(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public override {
        grandRoleNewOwner(to);
        _safeTransfer(from, to, tokenId, data);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        grandRoleNewOwner(to);
        _safeTransfer(from, to, tokenId, "");
    }

    function sellItem(
        StatusOrder _orderType,
        address target,
        address paymentToken,
        bytes32 _hashOrder,
        bytes calldata _data,
        uint256 _price,
        uint256 _nftId,
        uint256 _amount
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_orderType == StatusOrder.ERC721) {
            IERC721(target).approve(market, _nftId);
        } else if (_orderType == StatusOrder.ERC1155) {
            IERC1155(target).setApprovalForAll(market, true);
        }
        IMarket(market).createOrder(
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
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(nft != address(0));
        IERC721(nft).safeTransferFrom(address(this), _to, _tokenId);
    }

    function multiWithdraw(
        address erc721,
        address erc1155,
        address receiver,
        uint[] calldata ids,
        uint[] calldata _tokenIds,
        uint[] calldata _amounts
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(erc721 != address(0));
        require(erc1155 != address(0));
        require(_tokenIds.length == _amounts.length);
        for (uint256 i = 0; i < ids.length; i++) {
            IERC721(erc721).safeTransferFrom(
                address(this),
                receiver,
                ids[i],
                ""
            );
        }
        IERC1155(erc1155).safeBatchTransferFrom(
            address(this),
            receiver,
            _tokenIds,
            _amounts,
            ""
        );
    }

    function witdhraw1155(
        address collection,
        address _to,
        uint256 _tokenId,
        uint256 amount,
        bytes calldata _data
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(collection != address(0));
        IERC1155(collection).safeTransferFrom(
            address(this),
            _to,
            _tokenId,
            amount,
            _data
        );
    }

    function batchTransfer1155(
        address collection,
        address _to,
        uint256[] calldata tokenIDs,
        uint256[] calldata tokenAmount
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(collection != address(0));
        IERC1155(collection).safeBatchTransferFrom(
            address(this),
            _to,
            tokenIDs,
            tokenAmount,
            ""
        );
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC1155Receiver, ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
