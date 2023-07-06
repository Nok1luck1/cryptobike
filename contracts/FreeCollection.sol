//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./interface/IByke.sol";

contract FreeCollection is
    ERC1155,
    ERC1155URIStorage,
    ERC1155Burnable,
    AccessControl
{
    using Strings for uint256;
    using ECDSA for bytes32;

    address private bikeNFT;
    address private signer;
    uint256 public freeAccessID;
    bytes32 public constant SIGNATURE_CHECKER = keccak256("SIGNATURE_CHECKER");
    struct DataMB {
        address account;
        uint256 burnID;
        uint256 mintID;
        uint256 expiry;
    }
    struct HashSig {
        bytes32 msgHash;
        bytes signature;
    }
    mapping(bytes32 => bool) private hashes;
    mapping(address => mapping(uint256 => bool)) public userMinted;
    event SignerChanged(address oldSigner, address newSigner);

    constructor(address _bikeNFT, address _signer) ERC1155("") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        bikeNFT = _bikeNFT;
        signer = _signer;
        setBaseURI("https:/pornhub/qwefdqw/");
    }

    function changeSigner(
        address newSigner
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        emit SignerChanged(signer, newSigner);
        signer = newSigner;
    }

    function changeBykeNFT(address byke) external onlyRole(DEFAULT_ADMIN_ROLE) {
        bikeNFT = byke;
    }

    function isValidSig(
        HashSig memory hashSig
    ) public view returns (bool isValid) {
        address _signer = ECDSA.recover(hashSig.msgHash, hashSig.signature);
        return !hashes[hashSig.msgHash] && _signer == signer;
    }

    function getMessageHash(DataMB memory data) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    data.account,
                    data.burnID,
                    data.mintID,
                    data.expiry
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

    function burnAndMint(DataMB memory data, bytes memory sig) public {
        bytes32 msgHash = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                keccak256(
                    abi.encodePacked(
                        data.account,
                        data.burnID,
                        data.mintID,
                        data.expiry
                    )
                )
            )
        );
        require(isValidSig(HashSig(msgHash, sig)), "Invalid signature");
        require(data.account == msg.sender, "Invalid account");
        require(data.expiry > block.timestamp, "Expired");
        hashes[msgHash] = true;
        burn(msg.sender, data.burnID, 1);
        IByke(bikeNFT).mint(msg.sender, data.mintID);
    }

    function setURI(
        uint256 id,
        string memory urL
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setURI(id, urL);
    }

    function setBaseURI(
        string memory _baseURI
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setBaseURI(_baseURI);
    }

    function setNewFreeItem(uint256 id) public onlyRole(DEFAULT_ADMIN_ROLE) {
        freeAccessID = id;
    }

    function freeMint() public {
        require(
            userMinted[msg.sender][freeAccessID] == false,
            "Cant mint more"
        );
        _mint(msg.sender, freeAccessID, 1, "");
        userMinted[msg.sender][freeAccessID] == true;
    }

    function mint(
        address _to,
        uint256 _tokenId,
        uint256 _amount,
        string memory urL,
        bytes memory _data
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        setURI(_tokenId, urL);
        _mint(_to, _tokenId, _amount, _data);
    }

    function mint(
        address to,
        uint256 tokenId,
        uint256 amount
    ) public returns (bool) {
        require(
            hasRole(SIGNATURE_CHECKER, _msgSender()) ||
                hasRole(DEFAULT_ADMIN_ROLE, _msgSender())
        );
        _mint(to, tokenId, amount, "");
        return true;
    }

    function uri(
        uint256 tokenID
    )
        public
        view
        virtual
        override(ERC1155URIStorage, ERC1155)
        returns (string memory)
    {
        return ERC1155URIStorage.uri(tokenID);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public override {
        safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public override {
        safeBatchTransferFrom(from, to, ids, amounts, data);
    }
}
