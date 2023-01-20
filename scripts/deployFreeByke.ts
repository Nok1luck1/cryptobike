import { deploy } from "@openzeppelin/hardhat-upgrades/dist/utils";
import { ethers } from "hardhat";
const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(deployer.address, "deployed address");
  const FactoryMarketContr = await ethers.getContractFactory("FreeByke");

  const market = await FactoryMarketContr.deploy(
    "https://bafybeid3w4wyq7lhabndmllpqs34wak5jk5vittkuexzl35bxr5nwgcdde.ipfs.nftstorage.link/"
  );
  await market.deployed();
  console.log(`Market address : ${market.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
