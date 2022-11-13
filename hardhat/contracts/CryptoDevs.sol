// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract CryptoDevs is ERC721Enumerable, Ownable {

    //Variables
    //For computing tokenURI. If set, will make tokenURI baseURI + TokenId concatenation
    string _baseTokenURI;

    //_price of one NFT
    uint256 public _price = 0.01 ether;

    // max number of NFTs
    uint256 public maxTokenIds = 20;
    
    //_pause is used to pause contract in case of emergency
    bool public _paused;

    // total # of tokenIds minted
    uint256 public tokenIds;

    // Whitelist contract instance
    IWhitelist whitelist;

    // Bool to keep track of whether presale has started
    bool public presaleStarted;

    // timestamp for when presale ends
    uint256 public presaleEnded;

    modifier onlyWhenNotPaused {
        require(!_paused, "Contract currently paused");
        _;
    }

    constructor (string memory baseURI, address whitelistContract) ERC721("Crypto Devs", "CD") {
        _baseTokenURI = baseURI;
        whitelist = IWhitelist(whitelistContract);
    }

    //Start a presale for whitelisted addresses
    function startPresale() public onlyOwner {
        presaleStarted = true;
        presaleEnded = block.timestamp + 5 minutes;
    }

    //Allow whitelisted user to mint 1 token during presale
    function presaleMint() public payable onlyWhenNotPaused {
        require(presaleStarted && block.timestamp < presaleEnded, "Presale is not running");
        require(whitelist.whitelistedAddresses(msg.sender), "You are not whitelisted");
        require(tokenIds < maxTokenIds, "Exceeds maximum Crypto Devs supply");
        require(msg.value >= _price, "Ether sent is not correct");
        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }

    //_basURI overides Openzeppelin's ERC721 which returns an empty string by default
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    //setPaused will pause or unpause the contract
    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }

    //Send all ether in contract to owner
    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    //Function to receive Ether. msg.data must be empty
    receive() external payable {}

    //Fallback function is called when msg.data is not empty
    fallback() external payable {}
}