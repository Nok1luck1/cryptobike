import { ethers, upgrades } from "hardhat";
const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(deployer.address, "deployed address");
  const FactoryMarketContr = await ethers.getContractFactory("FactoryMarket");
  const initValue = [
    deployer.address, //must be owner
  ];
  const market = await upgrades.deployProxy(FactoryMarketContr, initValue, {
    initializer: "initialize",
    kind: "uups",
  });
  await market.deployed();
  console.log(`Market address : ${market.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
