require("dotenv").config();

module.exports = {
  defaultNetwork: "sepolya",
  networks: {
    hardhat: {},
    ethers: {
      url: process.env.INFURA_URL_ETH,
      accounts: [process.env.PRIVATE_KEY],
    },
    base: {
      url: process.env.BASE_RPC,
      accounts: [process.env.PRIVATE_KEY],
    },
    sepolya: {
      url: process.env.INFURA_URL_SEPOLYA,
      accounts: [process.env.PRIVATE_KEY],
    },
    mumbai: {
      url: process.env.MUMBAI_RPC_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
    bsc: {
      url: process.env.BSC_TESTNET_RPC_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 4,
      },
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};
