const Creator = artifacts.require("Creator");
const Character = artifacts.require("Character");
const Fragment = artifacts.require("Fragment");
const Item = artifacts.require("Item");
const Weapon = artifacts.require("Weapon");
const MockToken = artifacts.require("MockToken");

module.exports = async function (deployer) {
    const character = await Character.deployed();
    const fragment = await Fragment.deployed();
    const item = await Item.deployed();
    const weapon = await Weapon.deployed();

    // Set mainnet token address here
    let tokenAddress = "";
    if (deployer.network == 'dev' || deployer.network == 'testnet') {
        await deployer.deploy(MockToken, "Salo Token", "SLT");
        const token = await MockToken.deployed();
        tokenAddress = token.address;
    }

    // settings fee
    const fee = 0
    await deployer.deploy(Creator, fee, tokenAddress, character.address, fragment.address, item.address, weapon.address);
    const creator = await Creator.deployed();
    if(creator) {
        console.log("Creator successfully deployed.");
        console.log(`Creator address: ${creator.address}`);

        await character.setMinterRole(creator.address);
        await fragment.setMinterRole(creator.address);
        await item.setMinterRole(creator.address);
        await weapon.setMinterRole(creator.address);
    }
}
