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
    uint256 listprice = 0.01 ether;

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
        require(listprice = msg.sender, "only owner can up listing price");
        listprice = _listPrice;
    }
}
