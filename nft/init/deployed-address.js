const { exit } = require("process");

const Character = artifacts.require("Character");
const Item = artifacts.require("Item");
const Fragment = artifacts.require("Fragment");
const Weapon = artifacts.require("Weapon");
const Creator = artifacts.require("Creator");

module.exports = async function(callback) {
    const characterInstance = await Character.deployed();
    if(characterInstance) {
        console.log(`Character address: ${characterInstance.address}`);
    }

    const itemInstance = await Item.deployed();
    if(itemInstance) {
        console.log(`Item address: ${itemInstance.address}`);
    }

    const fragmentInstance = await Fragment.deployed();
    if(fragmentInstance) {
        console.log(`Fragment address: ${fragmentInstance.address}`);
    }

    const weaponInstance = await Weapon.deployed();
    if(weaponInstance) {
        console.log(`Weapon address: ${weaponInstance.address}`);
    }

    const creatorInstance = await Creator.deployed();
    if(creatorInstance) {
        console.log(`Creator address: ${creatorInstance.address}`);
    }

    exit(0);
}
