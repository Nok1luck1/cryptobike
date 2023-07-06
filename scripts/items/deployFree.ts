import { deploy } from "@openzeppelin/hardhat-upgrades/dist/utils";
import { ethers } from "hardhat";
const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(deployer.address, "deployed address");
  const FactoryMarketContr = await ethers.getContractFactory("FreeCollection");
  //set url in constructor
  const byke = "";
  const signer = "";
  const collection = await FactoryMarketContr.deploy(byke, signer);
  await collection.deployed();
  console.log(`collection address : ${collection.address}`);
  // const mintED = await collection.freeMint();
  // console.log(mintED);
  // const mintED1 = await collection.freeMint();
  //console.log(mintED1);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
