const { exit } = require("process");

const Marketplace = artifacts.require("Marketplace");

module.exports = async function(callback) {
    const marketplaceInstance = await Marketplace.deployed();
    if(marketplaceInstance) {
        console.log(`Marketplace address: ${marketplaceInstance.address}`);
    }

    exit(0);
}
