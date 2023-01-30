import { deploy } from "@openzeppelin/hardhat-upgrades/dist/utils";
import { ethers, updates } from "hardhat";
const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(deployer.address, "deployed address");
  const FactoryMarketContr = await ethers.getContractFactory("FactoryMarket");
  const initValue = [deployer.address];
  const market = await upgrades.deployProxy(FactoryMarketContr, initValue, {
    initializer: "initialize",
    kind: "uups",
  });

  await market.deployed();
  const nft = await ethers.getContractFactory("TESTERC721");
  const NFT = await nft.deploy();
  await NFT.deployed();
  const mint = NFT.mint(deployer.address, 0);
  const mint2 = NFT.mint(deployer.address, 2);
  const mint3 = NFT.mint(deployer.address, 3);
  console.log(`Market address : ${market.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
