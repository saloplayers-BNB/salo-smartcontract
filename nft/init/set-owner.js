const { exit } = require("process");

const Character = artifacts.require("Character");
const Item = artifacts.require("Item");
const Fragment = artifacts.require("Fragment");
const Weapon = artifacts.require("Weapon");
const Creator = artifacts.require("Creator");

module.exports = async function (callback) {
    const newOwner = "";

    const characterInstance = await Character.deployed();
    if(characterInstance) {
        console.log(`Character address: ${characterInstance.address}`);
        await characterInstance.transferOwnership(newOwner);
    }

    const fragmentInstance = await Fragment.deployed();
    if(fragmentInstance) {
        console.log(`Fragment address: ${fragmentInstance.address}`);
        await fragmentInstance.transferOwnership(newOwner);
    }

    const itemInstance = await Item.deployed();
    if(itemInstance) {
        console.log(`Item address: ${itemInstance.address}`);
        await itemInstance.transferOwnership(newOwner);
    }

    const weaponInstance = await Weapon.deployed();
    if(weaponInstance) {
        console.log(`Weapon address: ${weaponInstance.address}`);
        await weaponInstance.transferOwnership(newOwner);
    }

    const creatorInstance = await Creator.deployed();
    if(console) {
        console.log(`Creator address: ${creatorInstance.address}`);
        await creatorInstance.transferOwnership(newOwner);
    }

    exit(0);
}
