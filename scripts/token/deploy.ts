import { ethers, upgrades } from "hardhat";
const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(deployer.address, "deployed address");
  const TOKENcontr = await ethers.getContractFactory("MTCB");
  const initValue = ["0x71c5694B5D892BDC259926692fc6A50582B84B9F"];
  const token = await upgrades.deployProxy(TOKENcontr, initValue, {
    initializer: "initialize",
    kind: "uups",
  });
  await token.deployed();

  console.log(`${token.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
