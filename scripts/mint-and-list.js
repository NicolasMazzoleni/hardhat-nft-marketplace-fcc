const { ethers } = require("hardhat")

// launch local blockchain yarn hardhat node
// execute script yarn hardhat run scripts/mint-and-list.js --network localhost

const PRICE = ethers.utils.parseEther('0.1')

async function mintAndList() {
    const nftMarketplace = await ethers.getContract("NftMarketplace")
    const basicNft = await ethers.getContract("BasicNft")
    console.log('Minting NFT...')
    
    const mintTransaction = await basicNft.mintNft()
    const mintTransactionRecepit = await mintTransaction.wait(1)
    
    // Get the tokenId through the emiited event DogMinted()
    const tokenId = mintTransactionRecepit.events[0].args.tokenId
    console.log('Approving NFT...')

    const approvedTransaction = await basicNft.approve(nftMarketplace.address, tokenId)
    await approvedTransaction.wait(1)
    console.log("Listing NFT...")

    const listedItem = await nftMarketplace.listItem(basicNft.address, tokenId, PRICE)
    await listedItem.wait(1)
    console.log('Listed !')
}

mintAndList()
    .then(() => process.exit(0))
    .catch((error) => {
        console.log(error)
        process.exit(1)
    })