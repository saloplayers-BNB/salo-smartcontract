const Marketplace = artifacts.require("Marketplace");
const MockNft = artifacts.require("MockNft");

module.exports = async function(deployer) {
    let ownerCutPerMillion = 10000;

    await deployer.deploy(Marketplace, ownerCutPerMillion);

    const marketplace = await Marketplace.deployed();
    if (marketplace) {
        console.log("Marketplace successfully deployed.");
        console.log(`Marketplace address: ${marketplace.address}`);
    }

    if (deployer.network == 'dev' || deployer.network == 'testnet') {
        await deployer.deploy(MockNft);
    }
}
