require("dotenv").config();
import "solidity-coverage";
import "@typechain/hardhat";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-waffle";
require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require("hardhat-gas-reporter");
require("hardhat-contract-sizer");
import "hardhat-abi-exporter";
require("@openzeppelin/hardhat-upgrades");
require("@nomiclabs/hardhat-web3");

const dotenv = require("dotenv");
dotenv.config({ path: __dirname + "/.env" });
const { PRIVATE_KEY } = process.env;
const { COINMARKETCAP_API_KEY } = process.env;

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      // forking: {
      //   url: "https://mainnet.infura.io/v3/39bf211ec4024c1ab7951c072b81d833",
      //   // specify a block to fork from
      //   // remove if you want to fork from the last block
      //   blockNumber: 14674245,
      // },
      gasReporter: {
        enabled: true,
        gasPriceApi:
          "https://api.bscscan.com/api?module=proxy&action=eth_gasPrice",
        gasPrice: 5,
        onlyCalledMethods: false,
        currency: "USD",
        token: "BNB",
        coinmarketcap: "5cde3840-e602-4399-b5a1-608996f9f0da",
      },
    },
    localhost: {
      url: "http://127.0.0.1:7545",
    },
    node: {
      url: "https://node.thetrade.pro/rpc",
    },
    polygontest: {
      url: "https://polygon-mumbai.infura.io/v3/c0846c0936794c209285d51868f1ad77",
      chainId: 80001,
      gasPrice: 50943655893,
      accounts: [PRIVATE_KEY],
      timeout: 1000,
      networkCheckTimeout: 1000000,
      pollingInterval: 10000,
      timeoutBlocks: 200,
    },
    polygonMain: {
      url: "https://polygon-mainnet.infura.io/v3/b49715c32e5c48488445d21313b02837",
      chainId: 137,
      gasPrice: 466300000000,
      accounts: [PRIVATE_KEY],
      prodution: true,
      skipDryRun: true,
      timeout: 1000,
      networkCheckTimeout: 1000000,
      pollingInterval: 10000,
      timeoutBlocks: 1000,
    },
    mainnetBSC: {
      url: "https://bsc-dataseed.binance.org/",
      chainId: 56,
      gasPrice: 5000000000,
      accounts: [PRIVATE_KEY],
    },
    bscTestnet: {
      url: "https://data-seed-prebsc-1-s3.binance.org:8545/",
      chainId: 97,
      gasPrice: 20e9,
      accounts: [PRIVATE_KEY],
    },
    mainnet: {
      url: "https://mainnet.infura.io/v3/b49715c32e5c48488445d21313b02837",
      chainId: 1,
      gasPrice: 16000000000,
      accounts: [PRIVATE_KEY],
    },
    rinkeby: {
      url: "https://rinkeby.infura.io/v3/c0846c0936794c209285d51868f1ad77",
      chainId: 4,
      gasPrice: 1900000000,
      accounts: [PRIVATE_KEY],
    },
    goerli: {
      url: "https://goerli.infura.io/v3/39bf211ec4024c1ab7951c072b81d833",
      chainId: 5,
      gasPrice: 30000000000,
      accounts: [PRIVATE_KEY],
      networkCheckTimeout: 1000000000,
      pollingInterval: 1000,
      timeoutBlocks: 10000000,
    },
    ropsten: {
      url: "https://ropsten.infura.io/v3/c0846c0936794c209285d51868f1ad77",
      chainId: 3,
      gasPrice: 1200000000,
      accounts: [PRIVATE_KEY],
    },
    palmTest: {
      url: "https://palm-testnet.infura.io/v3/c0846c0936794c209285d51868f1ad77",
      chainId: 4,
      gasPrice: 1900000000,
      accounts: [PRIVATE_KEY],
    },
    nearTest: {
      url: "https://near-testnet.infura.io/v3/c0846c0936794c209285d51868f1ad77",
      chainId: 4,
      gasPrice: 1900000000,
      accounts: [PRIVATE_KEY],
    },
    Starknet: {
      url: "https://starknet-mainnet.infura.io/v3/c0846c0936794c209285d51868f1ad77",
      chainId: 4,
      gasPrice: 1900000000,
      accounts: [PRIVATE_KEY],
    },
    StarknetTest: {
      url: "https://starknet-goerli.infura.io/v3/c0846c0936794c209285d51868f1ad77",
      chainId: 4,
      gasPrice: 1900000000,
      accounts: [PRIVATE_KEY],
    },
    Avaxfuji: {
      url: "https://api.avax-test.network/ext/bc/C/rpc",
      chainId: 43113,
      accounts: [PRIVATE_KEY],
    },
    moonrivermain: {
      url: "https://rpc.moonriver.moonbeam.network",
      chainId: 1285,
      accounts: [PRIVATE_KEY],
    },
    moonbeamtest: {
      url: "https://rpc.testnet.moonbeam.network",
      chainId: 1287,
      accounts: [PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: {
      ropsten: "H976DUPQP2KFCFB84ZTTC2GW6RHIHEEWRK",
      mainnet: "H976DUPQP2KFCFB84ZTTC2GW6RHIHEEWRK",
      rinkeby: "H976DUPQP2KFCFB84ZTTC2GW6RHIHEEWRK",
      goerli: "H976DUPQP2KFCFB84ZTTC2GW6RHIHEEWRK",
      kovan: "H976DUPQP2KFCFB84ZTTC2GW6RHIHEEWRK",
      bsc: "F596YW6S58BIA6NBUM23ZZZ7AZGDNB2V8N",
      bscTestnet: "WES9KS3YFTT6VZU92TRA3TIK3GBZI3E1U2",
      heco: "6TJU13WA357W1YFIQI3S9HM2GVF1E7WZEI",
      hecoTestnet: "6TJU13WA357W1YFIQI3S9HM2GVF1E7WZEI",
      opera: "GW6QZKHE1NMBJF25YJBJCPUA1RMJA2DQNS",
      ftmTestnet: "GW6QZKHE1NMBJF25YJBJCPUA1RMJA2DQNS",
      optimisticEthereum: "KW65HGUSMTTVR8NDX9FJ986JTWC2HUY4UV",
      polygon: "YNW28KKR9B2IZ62ARK2SEIW2D41ZMWJD5R",
      polygonMumbai: "YNW28KKR9B2IZ62ARK2SEIW2D41ZMWJD5R",
      arbitrumOne: "NRFSTYK86TXES95DKF731NKWR3JNTTHS7K",
      arbitrumTestnet: "NRFSTYK86TXES95DKF731NKWR3JNTTHS7K",
      avalanche: "1KVXGRF1KI292HTYBQGGA5UB3UXGV29HI5",
      avalancheFujiTestnet: "1KVXGRF1KI292HTYBQGGA5UB3UXGV29HI5",
      moonriver: "U9VSKKU8STYVITYCFMP225JYXJPW9Q8453",
      moonbaseAlpha: "U9VSKKU8STYVITYCFMP225JYXJPW9Q8453S",
      xdai: "api-key",
      sokol: "api-key",
    },
    gasReporter: {
      enabled: true,
      onlyCalledMethods: false,
      // gasPriceApi:
      //   "https://api.bscscan.com/api?module=proxy&action=eth_gasPrice",
      gasPrice: 5,
      //currency: "2781",
      //token: "BNB",
      coinmarketcap: "5cde3840-e602-4399-b5a1-608996f9f0da",
    },
  },
  solidity: {
    compilers: [
      {
        version: "0.8.17",
        settings: {
          viaIR: false,
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.8.4",
        settings: {
          viaIR: false,
          optimizer: {
            enabled: true,
            runs: 20,
          },
        },
      },
    ],
    outputSelection: {
      "*": {
        "*": ["storageLayout"],
      },
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  // mocha: {
  //   reporter: "eth-gas-reporter",
  //   timeout: 200000,
  // },
};
