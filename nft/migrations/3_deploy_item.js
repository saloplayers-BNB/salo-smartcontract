const Item = artifacts.require("Item");

module.exports = async function(deployer) {
    await deployer.deploy(Item);
    const item = await Item.deployed();
    if(item) {
        console.log("Item successfully deployed.");
        console.log(`Item address: ${item.address}`);
    }
}
