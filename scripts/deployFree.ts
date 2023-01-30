import { deploy } from "@openzeppelin/hardhat-upgrades/dist/utils";
import { ethers } from "hardhat";
const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(deployer.address, "deployed address");
  const FactoryMarketContr = await ethers.getContractFactory("FreeCollection");

  const collection = await FactoryMarketContr.deploy(
    0,
    "https://bafybeid3w4wyq7lhabndmllpqs34wak5jk5vittkuexzl35bxr5nwgcdde.ipfs.nftstorage.link/"
  );
  await collection.deployed();
  console.log(`collection address : ${collection.address}`);
  const mintED = await collection.freeMint();
  console.log(mintED);
  const mintED1 = await collection.freeMint();
  console.log(mintED1);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
