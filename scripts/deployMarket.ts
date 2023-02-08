import { deploy } from "@openzeppelin/hardhat-upgrades/dist/utils";
import { ethers } from "hardhat";
const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(deployer.address, "deployer address");
  const FactoryMarketContr = await ethers.getContractFactory(
    "FactoryMarketNonProx"
  );
  const initValue = [deployer.address];
  const market = await FactoryMarketContr.deploy();

  await market.deployed();
  console.log(market.address, "market");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
