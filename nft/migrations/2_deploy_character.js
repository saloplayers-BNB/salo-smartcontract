const Character = artifacts.require("Character");

module.exports = async function(deployer) {
    await deployer.deploy(Character);
    const character = await Character.deployed();
    if(character) {
        console.log("Character successfully deployed.")
        console.log(`Character address: ${character.address}`);
    }
}
