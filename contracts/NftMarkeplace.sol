// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

error NftMarketplace__PriceMustBeGreaterThanZero();

contract NftMarketplace {

    // Main Functions
    function listItem(address nftContractAddress, uint256 ContractTokenId, uint256 price) external {
        if (price <= 0) {
            revert NftMarketplace__PriceMustBeGreaterThanZero;
        }
    }
}

//     1. ListItem : List NFT on the marketplace
//     2. BuyItem : Buy the NFTs
//     3. CancelItem : Cancel a listing
//     4. UpdateListing : Update the price of an NFT
//     5. WithdrawProceeds : Withdraw payment for my bought NFTs