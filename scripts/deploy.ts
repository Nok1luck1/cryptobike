import { ethers, upgrades } from "hardhat";
const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(deployer.address, "deployed address");
  const FactoryMarketContr = await ethers.getContractFactory("CryptoBike");
  const initValue = ["zalupa", "ZLP"];
  const market = await upgrades.deployProxy(FactoryMarketContr, initValue, {
    initializer: "initialize",
    kind: "uups",
  });
  await market.deployed();
  console.log(`Market address : ${market.address}`);
  const NAME = await market.name();
  console.log(NAME);
  const string = await market.symbol();
  console.log(string);
  const mint = await market.mint(0, deployer.address);

  const link = "https://testnet.bscscan.com/address";
  const setURI = await market.setURI(0, link);
  const uri = await market.tokenURI(0);
  const balance = await market.balanceOf(deployer.address);
  console.log(`${uri}`);
  console.log(balance);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
