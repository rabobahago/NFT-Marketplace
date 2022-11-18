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

    function createToken(string memory tokenURI, uint256 price) public payable {
        require(msg.value == listPrice, "send enough ether to list");
        require(msg.value > 0, "ether price must be positive");
        _tokenIds.increment();
        uint256 currentTokenId = _tokenIds.current();
        //_safeMint make sure that the contract to send the token has the necessary capability to receive ether
        _safeMint(msg.sender, currentTokenId);
        //set current token to tokenURI that is coming from the frontend
        _setTokenURI(currentTokenId, tokenURI);
        //pass to createListedToken currentTokenId and price
        createListedToken(currentTokenId, price);
        return currentTokenId;
    }

    function createListedToken(uint256 tokenId, uint256 price) private {
        idToListedToken[tokenId] = listedToken(
            tokenId,
            payable(address(this)),
            payable(msg.sender),
            price,
            true
        );
        _transfer(msg.sender, address(this), tokenId);
    }

    function getAllNFTs() public view returns (listedToken[] memory) {
        int256 nftCount = _tokenIds.current();
        listedToken[] memory tokens = new listedToken[](nftCount);
        uint currentIndex = 0;

        for (uint i = 0; i < nftCount; i++) {
            uint256 currentId = i + 1;
            listedToken storage currentItem = idToListedToken[currentId];
            tokens[currentIndex] = currentItem;
            currentIndex += 1;
        }
        return tokens;
    }
}
