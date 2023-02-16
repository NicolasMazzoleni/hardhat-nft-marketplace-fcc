// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

error NftMarketplace__PriceMustBeGreaterThanZero();
error NftMarketplace__NotApprovedForMarketplace();

contract NftMarketplace {

    // Main Functions
    function listItem(address nftContractAddress, uint256 ContractTokenId, uint256 price) external {
        address currentAddress = address(this);

        if (price <= 0) {
            revert NftMarketplace__PriceMustBeGreaterThanZero();
        }

        IERC721 nft = IERC721(nftContractAddress); // Using the Interface here
        if (nft.getApproved(ContractTokenId) != currentAddress) {
            revert NftMarketplace__NotApprovedForMarketplace();
        }

    }
}

//     1. ListItem : List NFT on the marketplace
//     2. BuyItem : Buy the NFTs
//     3. CancelItem : Cancel a listing
//     4. UpdateListing : Update the price of an NFT
//     5. WithdrawProceeds : Withdraw payment for my bought NFTs