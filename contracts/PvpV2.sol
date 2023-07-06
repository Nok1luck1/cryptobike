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
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract PvpV2 is
    ERC721HolderUpgradeable,
    ERC1155HolderUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    address public items1155;
    address private signer;
    struct HashSig {
        bytes32 msgHash;
        bytes signature;
    }
    struct UserRaceParams {
        address sender;
        address receiver;
        uint256 expirationDate;
        address[] erc721;
        uint256[] id721;
        uint256[] itemsId;
        uint256[] itemsAmount;
    }

    mapping(bytes32 => bool) private hashes;
    event Deposited(
        address user,
        address[] nft,
        uint256[] id721,
        uint256[] itemsId,
        uint256[] itemsAmount
    );
    event SignerChanged(address oldSigner, address newSigner);

    function changeSigner(
        address newSigner
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        emit SignerChanged(signer, newSigner);
        signer = newSigner;
    }

    function initialize(address owner, address _items1155) public initializer {
        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(DEFAULT_ADMIN_ROLE, owner);
        __UUPSUpgradeable_init();
        signer = owner;
        items1155 = _items1155;
    }

    function depositItems(UserRaceParams memory _params) public {
        for (uint64 i = 0; i < _params.erc721.length; i++) {
            IERC721Upgradeable(_params.erc721[i]).safeTransferFrom(
                _msgSender(),
                address(this),
                _params.id721[i],
                ""
            );
        }

        IERC1155Upgradeable(items1155).safeBatchTransferFrom(
            _msgSender(),
            address(this),
            _params.itemsId,
            _params.itemsAmount,
            ""
        );
        emit Deposited(
            _msgSender(),
            _params.erc721,
            _params.id721,
            _params.itemsId,
            _params.itemsAmount
        );
    }

    function isValidSig(
        HashSig memory hashSig
    ) public view returns (bool isValid) {
        address _signer = ECDSA.recover(hashSig.msgHash, hashSig.signature);
        return !hashes[hashSig.msgHash] && _signer == signer;
    }

    function getMessageHash(
        UserRaceParams memory data
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    data.sender,
                    data.receiver,
                    data.expirationDate,
                    data.erc721,
                    data.id721,
                    data.itemsId,
                    data.itemsAmount
                )
            );
    }

    function getEthSignedMessageHash(
        bytes32 _messageHash
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _messageHash
                )
            );
    }

    function withdraw(UserRaceParams memory data, bytes memory sig) public {
        bytes32 msgHash = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                keccak256(
                    abi.encodePacked(
                        data.sender,
                        data.receiver,
                        data.expirationDate,
                        data.erc721,
                        data.id721,
                        data.itemsId,
                        data.itemsAmount
                    )
                )
            )
        );
        require(isValidSig(HashSig(msgHash, sig)), "Invalid signature");
        require(data.sender == msg.sender, "Invalid account");
        require(data.expirationDate > block.timestamp, "Expired");
        hashes[msgHash] = true;
        for (uint256 i = 0; i < data.erc721.length; i++) {
            IERC721Upgradeable(data.erc721[i]).safeTransferFrom(
                address(this),
                data.receiver,
                data.id721[i]
            );
        }
        IERC1155Upgradeable(items1155).safeBatchTransferFrom(
            address(this),
            data.receiver,
            data.itemsId,
            data.itemsAmount,
            ""
        );
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(AccessControlUpgradeable, ERC1155ReceiverUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}
}
