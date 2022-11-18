pragma solidity ^0.8.0;
import "hardhat/console.sol";
import "@openzepellin/contracts/utils/Counter.sol";
import "@openzepellin/contracts/token/ERC721/extensions/ERC721URIStorage";
import "@openzepellin/contracts/token/ERC721/ERC721.sol";

contract NFTMarketplace {
    address payable owner;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;
    uint256 listPrice = 0.01 ether;

    constructor() ERC721("NFTMarketplace", "NFTR") {
        owner = payable(msg.sender);
    }

    struct listedToken {
        uint256 tokenId;
        address payable owner;
        address payable sender;
        uint256 price;
        bool currentLsited;
    }
    mapping(uint256 => listedToken) private idToListedToken;

    function updatedListPrice(uint256 _listPrice) public payable {
        require(owner = msg.sender, "only owner can up listing price");
        listPrice = _listPrice;
    }

    function getListPrice() public view {
        return listPrice;
    }

    function getLatestIdToListedToken()
        public
        view
        returns (listedToken memory)
    {
        uint256 currentTokenId = _tokenIds.current();
        return idToListedToken[currentTokenId];
    }

    function getListedForTokenId(uint256 _tokenIds)
        public
        view
        returns (listedToken memory)
    {
        return idToListedToken[_tokenIds];
    }

    function getCurrentToken() public view returns (uint256) {
        return _tokenIds.current();
    }
}
