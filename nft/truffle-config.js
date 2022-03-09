require('dotenv').config();
const path = require('path');
const fs = require('fs');
const HDWalletProvider = require("@truffle/hdwallet-provider");
const mnemonic = process.env.MNEMONIC;
module.exports = {
  networks: {
    dev: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "5777"
    },
    testnet: {
      provider: () => new HDWalletProvider(mnemonic, `https://data-seed-prebsc-2-s3.binance.org:8545`),
      // provider: () => new HDWalletProvider(mnemonic, `https://data-seed-prebsc-1-s2.binance.org:8545/`),
      // provider: () => new HDWalletProvider(mnemonic, `https://data-seed-prebsc-2-s1.binance.org:8545/`),
      // provider: () => new HDWalletProvider(mnemonic, `https://data-seed-prebsc-2-s2.binance.org:8545/`),
      network_id: 97,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true,
      networkCheckTimeout: 99999
    },
    mainnet: {
      provider: () => new HDWalletProvider(mnemonic, `https://bsc-dataseed.binance.org`),
      network_id: "*",
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true
    },
  },
  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },
  compilers: {
    solc: {
      version: '0.8.4', // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      // settings: {          // See the solidity docs for advice about optimization and evmVersion
      //  optimizer: {
      //    enabled: false,
      //    runs: 200
      //  },
      //  evmVersion: "byzantium"
      // }
    },
  },
  api_keys: {
    etherscan: process.env.ETHERSCAN,
    bscscan: process.env.BSCSCAN
  },
  contracts_directory: path.resolve(__dirname, 'contracts'),
  plugins: ["truffle-plugin-verify"],
};
