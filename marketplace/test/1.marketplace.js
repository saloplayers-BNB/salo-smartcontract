const { time } = require("@openzeppelin/test-helpers");
const { web3 } = require("@openzeppelin/test-helpers/src/setup");
const { toWei } = web3.utils;
const bnChai = require('bn-chai');
const expect = require('chai')
  .use(bnChai(web3.utils.BN)) // web3 is provided by the test runner in truffle
  .expect;

const Marketplace = artifacts.require("Marketplace");
const MockNft = artifacts.require("MockNft");

contract('Marketplace', (accounts) => {
  it('create a order: MockNft', async () => {
    const user1 = accounts[1];
    const nftInstance = await MockNft.deployed();

    await nftInstance.mint(user1);
    const user1MockNfts = (await nftInstance.walletOfOwner.call(user1, 0, 10));

    expect(user1MockNfts.length).to.eq.BN(1);

    // Create order
    const marketplaceInstance = await Marketplace.deployed();

    const publicationFee = toWei('2');
    await marketplaceInstance.setPublicationFee(publicationFee);

    await nftInstance.approve(marketplaceInstance.address, user1MockNfts[0], {from: user1});

    const {start, end} = await getTime(5);
    const price = toWei('10');
    await marketplaceInstance.createOrder(
      nftInstance.address,
      user1MockNfts[0],
      price,
      start,
      end,
      {from: user1, value: publicationFee}
    );

    const order = (await marketplaceInstance.getOrder.call(nftInstance.address, user1MockNfts[0]));
    expect(order.id).not.to.eq.BN(0);
  });

  it('execute a order: MockNft', async () => {
    await time.increase(120);

    const user2 = accounts[2];
    const nftInstance = await MockNft.deployed();

    // Execute order
    const marketplaceInstance = await Marketplace.deployed();

    const cards = (await nftInstance.walletOfOwner.call(marketplaceInstance.address, 0, 10));
    const order = (await marketplaceInstance.getOrder.call(nftInstance.address, cards[0]));
    expect(order.id).not.to.eq.BN(0);

    await marketplaceInstance.executeOrder(
      nftInstance.address,
      cards[0],
      {from: user2, value: order.price}
    );

    const user2MockNfts = (await nftInstance.walletOfOwner.call(user2, 0, 10));
    expect(user2MockNfts.length).to.eq.BN(1);
  });

  async function getTime(minutesAhead = 1) {
    const block = await web3.eth.getBlock('latest')
    return {start: block.timestamp + 2*60, end: block.timestamp + minutesAhead*60}
  }
});
