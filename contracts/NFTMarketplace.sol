pragma solidity ^0.8.0;
import "hardhat/console.sol";
import "@openzepellin/contracts/utils/Counter.sol";
import "@openzepellin/contracts/token/ERC721/extensions/ERC721URIStorage";
import "@openzepellin/contracts/token/ERC721/ERC721.sol";

contract NFTMarketplace {
    constructor() ERC721("NFTMarketplace", "NFTR") {
        owner = payable(msg.sender);
    }
}
