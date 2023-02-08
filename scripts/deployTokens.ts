const Zakhar = "0x5C5193544Fce3f8407668D451b20990303cc692a";
import { ethers } from "hardhat";
const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(deployer.address, "deployeR address");
  const FactoryMarketContr = await ethers.getContractFactory("TEST");

  const token = await ethers.getContractFactory("MTCBToken");
  const deployTok = await token.deploy();
  await deployTok.deployed();

  console.log(deployTok.address);
  const market = await FactoryMarketContr.deploy();
  await market.deployed();
  await market.mint(Zakhar, "100000000000000000000");
  console.log(`Market address : ${market.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
