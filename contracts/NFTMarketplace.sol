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

    //Returns all the NFTs that the current user is owner or seller in
    function getMyNFTs() public view returns (ListedToken[] memory) {
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;
        uint currentId;
        //Important to get a count of all the NFTs that belong to the user before we can make an array for them
        for (uint i = 0; i < totalItemCount; i++) {
            if (
                idToListedToken[i + 1].owner == msg.sender ||
                idToListedToken[i + 1].seller == msg.sender
            ) {
                itemCount += 1;
            }
        }

        //Once you have the count of relevant NFTs, create an array then store all the NFTs in it
        ListedToken[] memory items = new ListedToken[](itemCount);
        for (uint i = 0; i < totalItemCount; i++) {
            if (
                idToListedToken[i + 1].owner == msg.sender ||
                idToListedToken[i + 1].seller == msg.sender
            ) {
                currentId = i + 1;
                ListedToken storage currentItem = idToListedToken[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function executeSale(uint256 tokenId) public payable {
        uint price = idToListedToken[tokenId].price;
        address seller = idToListedToken[tokenId].seller;
        require(
            msg.value == price,
            "Please submit the asking price in order to complete the purchase"
        );

        //update the details of the token
        idToListedToken[tokenId].currentlyListed = true;
        idToListedToken[tokenId].seller = payable(msg.sender);
        _itemsSold.increment();

        //Actually transfer the token to the new owner
        _transfer(address(this), msg.sender, tokenId);
        //approve the marketplace to sell NFTs on your behalf
        approve(address(this), tokenId);

        //Transfer the listing fee to the marketplace creator
        payable(owner).transfer(listPrice);
        //Transfer the proceeds from the sale to the seller of the NFT
        payable(seller).transfer(msg.value);
    }
}
