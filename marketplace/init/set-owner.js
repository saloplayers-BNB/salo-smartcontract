const { exit } = require("process");

const Marketplace = artifacts.require("Marketplace");

module.exports = async function (callback) {
    const newOwner = "";

    const marketplaceInstance = await Marketplace.deployed();
    if(marketplaceInstance) {
        console.log(`Marketplace address: ${marketplaceInstance.address}`);
        await marketplaceInstance.transferOwnership(newOwner);
    }

    exit(0);
}
