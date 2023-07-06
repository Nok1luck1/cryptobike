import { deploy } from "@openzeppelin/hardhat-upgrades/dist/utils";
import { ethers } from "hardhat";
const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(deployer.address, "deployed address");
  const FactoryMarketContr = await ethers.getContractFactory("Character");

  const name = "Character";
  const symbol = "CBR";
  const _baseUrl = "";
  const init = [name, symbol, _baseUrl];
  const market = await upgrades.deployProxy(FactoryMarketContr, init, {
    initializer: "initialize",
    kind: "uups",
  }); //url needed
  await market.deployed();
  console.log(`Market address : ${market.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
