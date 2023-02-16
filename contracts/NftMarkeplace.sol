// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error NftMarketplace__PriceMustBeGreaterThanZero();
error NftMarketplace__NotApprovedForMarketplace();
error NftMarketplace__NftAlreadyListed();
error NftMarketplace__NftNotListed();
// error NftMarketplace__NotOwner();
error NftMarketPlace__PayableAmountTooLow(address nftContractAddress, uint256 nftTokenId, uint256 payableAmount);

contract NftMarketplace is ReentrancyGuard, Ownable {
    // Creating a custom type
    struct Listing {
        uint256 price;
        address seller;
    }

    event ItemListed(
        address indexed caller,
        address indexed nft,
        uint256 indexed tokenId,
        uint256 price
    );

    event ItemBought(
        address indexed caller,
        address indexed nft,
        uint256 indexed tokenId,
        uint256 price
    );

    event ItemCancelled(        
        address indexed caller,
        address indexed nft,
        uint256 indexed tokenId
    );

    // Global variable
    // NFT Contract address -> NFT TokenIF -> Listing
    mapping(address => mapping(uint256 => Listing)) private s_listing;

    // Contract Caller Address => Amount earned
    mapping(address => uint256) private s_callerEarnedAmount;

    // Main Functions
    /*
     * @notice Method for listing NFT
     * @param nftContractAddress Address of NFT contract
     * @param NftTokenId Token ID of NFT
     * @param price sale price for each item
     */
    function listItem(address nftContractAddress, uint256 NftTokenId, uint256 price) external onlyOwner {
    // msg.sender is the address of the contract caller.
    // address(this) is the address of the smart contract itself.

        address smartContractAddress = address(this);
        address contractCallerAddress = msg.sender;

        if (price <= 0) {
            revert NftMarketplace__PriceMustBeGreaterThanZero();
        }

        // Using the Interface here
        IERC721 nft = IERC721(nftContractAddress); 
        if (nft.getApproved(NftTokenId) != smartContractAddress) {
            revert NftMarketplace__NotApprovedForMarketplace();
        }

        s_listing[nftContractAddress][NftTokenId] = Listing(price, contractCallerAddress);
        emit ItemListed(contractCallerAddress, nftContractAddress, NftTokenId, price);

        Listing memory listing = s_listing[nftContractAddress][NftTokenId];
        if (listing.price > 0) {
            revert NftMarketplace__NftAlreadyListed();
        }

        // address owner = nft.ownerOf(NftTokenId);
        // if (contractCallerAddress != owner) {
        //     revert NftMarketplace__NotOwner();
        // }
    }

    function buyItem(address nftContractAddress, uint256 nftTokenId) external payable nonReentrant {
        uint256 contractCallerPayableAmount = msg.value;
        address contractCallerAddress = msg.sender;


        Listing memory listing = s_listing[nftContractAddress][nftTokenId];
        if (listing.price <= 0) {
            revert NftMarketplace__NftNotListed();
        }

        if (contractCallerPayableAmount < listing.price) {
            revert NftMarketPlace__PayableAmountTooLow(nftContractAddress, nftTokenId, listing.price);
        }

        //We just don't send the money to the sender
        // It's waz better to have them withdraw the money

        s_callerEarnedAmount[listing.seller] = s_callerEarnedAmount[listing.seller] + contractCallerPayableAmount;
        
        // delete the entry in the mapping
        delete (s_listing[nftContractAddress][nftTokenId]);

        // transfer it
        IERC721(nftContractAddress).safeTransferFrom(listing.seller, contractCallerAddress, nftTokenId);

        // emit the event
        emit ItemBought(contractCallerAddress, nftContractAddress, nftTokenId, listing.price);
    }

    function cancelListing(address nftContractAddress, uint256 nftTokenId) external onlyOwner { 
        address contractCallerAddress = msg.sender;

        Listing memory listing = s_listing[nftContractAddress][nftTokenId];
        if (listing.price <= 0) {
            revert NftMarketplace__NftNotListed();
        }

        // delete the entry in the mapping
        delete (s_listing[nftContractAddress][nftTokenId]);

        // emit the event
        emit ItemCancelled(contractCallerAddress, nftContractAddress, nftTokenId);
    }

    function updateListing(address nftContractAddress, uint256 nftTokenId, uint256 newPrice) external onlyOwner {
        address contractCallerAddress = msg.sender;
        
        Listing memory listing = s_listing[nftContractAddress][nftTokenId];
            if (listing.price <= 0) {
                revert NftMarketplace__NftNotListed();
            }

        // update the price of an NFT
        s_listing[nftContractAddress][nftTokenId].price = newPrice;

        // emit the event
        emit ItemListed(contractCallerAddress, nftContractAddress, nftTokenId, newPrice);
    }
}

//     1. ListItem : List NFT on the marketplace ✅
//     2. BuyItem : Buy the NFTs ✅
//     3. CancelItem : Cancel a listing ✅
//     4. UpdateListing : Update the price of an NFT ✅
//     5. WithdrawProceeds : Withdraw payment for my bought NFTs