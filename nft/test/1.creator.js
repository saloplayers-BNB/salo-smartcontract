const bnChai = require('bn-chai');
const expect = require('chai')
  .use(bnChai(web3.utils.BN))
  .expect;

const Creator = artifacts.require("Creator");
const Character = artifacts.require("Character");
const MockToken = artifacts.require("MockToken");

contract('Creator', (accounts) => {
  const signer = web3.eth.accounts.create();

  it('set signer\'s address', async () => {
    const creator = await Creator.deployed();
    await creator.setSigner(signer.address);

    currentSigner = await creator.signer.call();
    expect(currentSigner).to.equal(signer.address);
  });

  it('should fail on wrong creator factory address', async () => {
    const user1 = accounts[1];

    const creator = await Creator.deployed();

    const character = await Character.deployed();
    await character.revokeMinterRole(creator.address);
    await character.setMinterRole(user1); // Set wrong address

    const metadataId = '1x';
    const nftType = 1; // Character

    // Sign message on server
    const message = await web3.utils.keccak256(
      web3.eth.abi.encodeParameters(
        ['uint8', 'string', 'address'],
        [nftType, metadataId, user1]
      )
    );

    const signed = signer.sign(message);

    try {
      await Creator.create(
        nftType, metadataId, signed.signature,
        {from: user1}
      );

      assert.fail('Expected throw not received');
    }
    catch (error) {
      assert.ok(error.reason == "Creator: failed to mint a nft", 'Expected throw received');
    }
  });

  it('Creator success', async () => {
    const user1 = accounts[1];

    const creator = await Creator.deployed();
    await creator.setFee(web3.utils.toBN(100));

    const token = await MockToken.deployed();
    await token.mint(user1, web3.utils.toBN(100));
    await token.approve(creator.address, web3.utils.toBN(100), {from: user1});

    const character = await Character.deployed();
    await character.setMinterRole(creator.address);

    const beforeUnbox = await character.balanceOf.call(user1);

    const metadataId = '1x';
    const nftType = 1; // Character

    // Sign message on server
    const message = await web3.utils.keccak256(
      web3.eth.abi.encodeParameters(
        ['uint8', 'string', 'address'],
        [nftType, metadataId, user1]
      )
    );

    const signed = signer.sign(message);

    await creator.create(
      nftType, metadataId, signed.signature,
      {from: user1}
    );

    const afterUnbox = await character.balanceOf.call(user1);

    expect(afterUnbox).to.eq.BN(beforeUnbox + 1);

    const balanceOfOwner = await token.balanceOf.call(accounts[0]);
    expect(balanceOfOwner).to.eq.BN(100);
  });

  it('fail on duplicate metadata', async () => {
    const user1 = accounts[1];

    const creator = await Creator.deployed();
    await creator.setFee(web3.utils.toBN(100));

    const token = await MockToken.deployed();
    await token.mint(user1, web3.utils.toBN(100));
    await token.approve(creator.address, web3.utils.toBN(100), {from: user1});

    const character = await Character.deployed();
    await character.setMinterRole(creator.address);

    const beforeUnbox = await character.balanceOf.call(user1);

    const metadataId = '1x';
    const nftType = 1; // Character

    // Sign message on server
    const message = await web3.utils.keccak256(
      web3.eth.abi.encodeParameters(
        ['uint8', 'string', 'address'],
        [nftType, metadataId, user1]
      )
    );

    const signed = signer.sign(message);

    try {
      await creator.create(
        nftType, metadataId, signed.signature,
        {from: user1}
      );

      assert.fail('Expected throw not received');
    }
    catch (error) {
      assert.ok(error.reason == "Creator: failed to mint a nft", 'Expected throw received');
    }
  });
});
