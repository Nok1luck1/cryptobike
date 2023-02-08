import { deploy } from "@openzeppelin/hardhat-upgrades/dist/utils";
import { ethers, upgrades } from "hardhat";
const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(deployer.address, "deployed address");
  const FactoryMarketContr = await ethers.getContractFactory("BinanceRemaster");
  const initValue = ["hueta", "EAF", "pornhub.com/"];
  const token = await upgrades.deployProxy(FactoryMarketContr, initValue, {
    initializer: "initialize",
    kind: "uups",
  });
  await token.deployed();
  const mint = await token.mint(deployer.address, 1);
  console.log(mint);
  const baalnce = await token.balanceOf(deployer.address);
  console.log(baalnce);
  //const burn = await token.burn(1);
  //console.log(burn);
  const baalnce1 = await token.balanceOf(deployer.address);
  console.log(baalnce1);
  console.log(`collection address : ${token.address}`);
  const URI = await token.tokenURI(1);
  console.log(URI);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
