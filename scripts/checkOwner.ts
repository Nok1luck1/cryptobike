import { deploy } from "@openzeppelin/hardhat-upgrades/dist/utils";
import { ethers } from "hardhat";
const hre = require("hardhat");
import Market from "../artifacts/contracts/FactoryMarket.sol/FactoryMarket.json";
async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(deployer.address, "deployed address");
  const FactoryMarketContr = await ethers.getContractAt(
    Market.abi,
    "0xEAC681A16cd621f078732D93431D3F5572b6fa1e"
  );
  const account = await FactoryMarketContr.generateAccount(123);
  console.log(`Market address : ${account}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
