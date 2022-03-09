const Weapon = artifacts.require("Weapon");

module.exports = async function(deployer) {
    await deployer.deploy(Weapon);
    const weapon = await Weapon.deployed();
    if(weapon) {
        console.log("Weapon successfully deployed.");
        console.log(`Weapon address: ${weapon.address}`);
    }
}
