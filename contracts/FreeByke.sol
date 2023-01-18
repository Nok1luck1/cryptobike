//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./interface/IFactoryMarket.sol";

contract NftBikes is ERC721URIStorage, AccessControl {
    using Counters for Counters.Counter;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    string public url;
    Counters.Counter public _globalCounter;

    mapping(address => bool) public userMinted;
    mapping(uint256 => string) private _tokenURIs;
    //mapping(uint256 => BikeType) public nftList;
    // struct BikeType {
    //     Counters.Counter counter;
    //     uint256 limit;
    //     uint256 price;
    // }
    //

    event Minted(uint256 _bikeType, uint256 _tokenId, address _to);

    constructor(
        string memory name,
        string memory symbol,
        string memory _url
    ) ERC721(name, symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        url = _url;
    }

    function freeMint(uint256 _bikeType) public {
        require(userMinted[msg.sender] == false, "Cant mint more");
        _safeMint(msg.sender, _globalCounter.current());
        _globalCounter.increment();
        //nftList[_bikeType].counter.increment();
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

        _safeMint(msg.sender, _globalCounter.current());
        _setTokenURI(_globalCounter.current(), link);
    }

    // function mint(address _to, uint256 _bikeType) public onlyRole(MINTER_ROLE) {
    //     require(nftList[_bikeType].price > 0, "This bike type can`t be minted");
    //     if (nftList[_bikeType].limit > 0) {
    //         require(
    //             nftList[_bikeType].counter.current() < nftList[_bikeType].limit,
    //             "The limit for this bike type has been reached."
    //         );
    //     }
    //
    //     _globalCounter.increment();
    //     uint256 newItemId = _globalCounter.current();
    //     string memory newId = Strings.toString(newItemId);
    //     string memory link = string(
    //         bytes.concat(
    //             bytes(url),
    //             bytes(Strings.toString(_bikeType)),
    //             "/",
    //             bytes(newId)
    //         )
    //     );

    //     _safeMint(_to, _globalCounter.current());
    //     _setTokenURI(_globalCounter.current(), link);
    //     emit Minted(_bikeType, _globalCounter.current(), _to);
    // }

    function setMinters(address _minter, address _contract)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        grantRole(MINTER_ROLE, _minter);
        grantRole(MINTER_ROLE, _contract);
    }

    function addMinter(address _minter) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(MINTER_ROLE, _minter);
    }

    function removeMinter(address _minter) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(MINTER_ROLE, _minter);
    }

    function setUrl(string memory _url) public onlyRole(DEFAULT_ADMIN_ROLE) {
        url = _url;
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
