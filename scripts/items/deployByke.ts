import { deploy } from "@openzeppelin/hardhat-upgrades/dist/utils";
import { ethers } from "hardhat";
const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(deployer.address, "deployed address");
  const FactoryMarketContr = await ethers.getContractFactory("BykeRentable");
  const name = "Byke";
  const signer = "";
  const symbol = "CBR";
  const _baseUrl = "";
  const init = [signer, name, symbol, _baseUrl];
  const collection = await upgrades.deployProxy(FactoryMarketContr, init, {
    initializer: "initialize",
    kind: "uups",
  });
  await collection.deployed();
  console.log(`collection address : ${collection.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
