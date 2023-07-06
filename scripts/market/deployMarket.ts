import { deploy } from "@openzeppelin/hardhat-upgrades/dist/utils";
import { ethers, upgrades } from "hardhat";
const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(deployer.address, "deployer address");
  //const FactoryMarketContr = await ethers.getContractFactory("Factory");
  const zakhar = "0x5C5193544Fce3f8407668D451b20990303cc692a";
  const markeet = await ethers.getContractFactory("RentMarket");
  const init = [zakhar];
  const market = await await upgrades.deployProxy(markeet, init, {
    initializer: "initialize",
    kind: "uups",
  });
  await market.deployed();
  // const initValue = [deployer.address];
  // const factory = await FactoryMarketContr.deploy(market.address, 30);
  // console.log(factory.address, "factory");
  // console.log(market.address, "market");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
