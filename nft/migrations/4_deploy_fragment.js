const Fragment = artifacts.require("Fragment");

module.exports = async function(deployer) {
    await deployer.deploy(Fragment);
    const fragment = await Fragment.deployed();
    if(fragment) {
        console.log("Fragment successfully deployed.");
        console.log(`Fragment address: ${fragment.address}`);
    }
}
