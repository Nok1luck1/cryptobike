//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NftBikes is ERC721URIStorage, AccessControl {
    using Counters for Counters.Counter;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    string public url;
    mapping(uint256 => string) private _tokenURIs;
    Counters.Counter public _globalCounter;

    struct BikeType {
        Counters.Counter counter;
        uint256 limit;
        uint256 price;
    }

    mapping(uint256 => BikeType) public nftList;

    event Minted(uint256 _bikeType, uint256 _tokenId, address _to);

    constructor(
        string memory name,
        string memory symbol,
        string memory _url
    ) ERC721(name, symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        url = _url;
    }

    function mint(address _to, uint256 _bikeType) public onlyMinters {
        require(nftList[_bikeType].price > 0, "This bike type can`t be minted");
        if (nftList[_bikeType].limit > 0) {
            require(
                nftList[_bikeType].counter.current() < nftList[_bikeType].limit,
                "The limit for this bike type has been reached."
            );
        }
        nftList[_bikeType].counter.increment();
        _globalCounter.increment();
        uint256 newItemId = _globalCounter.current();
        string memory newId = Strings.toString(newItemId);
        string memory link = string(
            bytes.concat(
                bytes(url),
                bytes(Strings.toString(_bikeType)),
                "/",
                bytes(newId)
            )
        );

        _safeMint(_to, _globalCounter.current());
        _setTokenURI(_globalCounter.current(), link);
        emit Minted(_bikeType, _globalCounter.current(), _to);
    }

    function setMinters(address _minter, address _contract) public onlyAdmin {
        grantRole(MINTER_ROLE, _minter);
        grantRole(MINTER_ROLE, _contract);
    }

    function addMinter(address _minter) public onlyAdmin {
        grantRole(MINTER_ROLE, _minter);
    }

    function removeMinter(address _minter) public onlyAdmin {
        revokeRole(MINTER_ROLE, _minter);
    }

    function setUrl(string memory _url) public onlyAdmin {
        url = _url;
    }

    function setBikeTypes(BikeType[] memory _array) public onlyAdmin {
        for (uint256 i = 0; i < _array.length; i++) {
            nftList[i + 1].price = _array[i].price;
            nftList[i + 1].limit = _array[i].limit;
        }
    }

    function setBikePrice(uint256 _bikeType, uint256 _price) public onlyAdmin {
        nftList[_bikeType].price = _price;
    }

    function removeBikeType(uint256 _bikeType) public onlyAdmin {
        delete nftList[_bikeType];
    }

    function getBikePrice(uint256 _bikeType) external view returns (uint256) {
        require(
            nftList[_bikeType].price != 0,
            "Sorry, we don't have bike with this type id"
        );
        return nftList[_bikeType].price;
    }

    modifier onlyAdmin() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Restricted to admins."
        );
        _;
    }

    modifier onlyMinters() {
        require(hasRole(MINTER_ROLE, msg.sender), "Restricted to admins.");
        _;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
