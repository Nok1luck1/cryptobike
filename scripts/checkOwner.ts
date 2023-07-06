import { deploy } from "@openzeppelin/hardhat-upgrades/dist/utils";
import { ethers } from "hardhat";
const hre = require("hardhat");
//import BykeRentable from "../artifacts/contracts/BykeRentable.sol/BykeRentable.json";
async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(deployer.address, "deployed address");
  const FactoryMarketContr = await ethers.getContractFactory("BykeRentable");
  const deploy = await FactoryMarketContr.deploy();
  //const account = await FactoryMarketContr.generateAccount(123);
  console.log(`Market address : ${deploy}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
