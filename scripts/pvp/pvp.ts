import { deploy } from "@openzeppelin/hardhat-upgrades/dist/utils";
import { ethers, upgrades } from "hardhat";
const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(deployer.address, "deployed address");
  const PVP = await ethers.getContractFactory("PvpV2");
  const items = "";
  const init = [deployer.address, items];
  const pvp = await upgrades.deployProxy(PVP, init, {
    initializer: "initialize",
    kind: "uups",
  });
  await pvp.deployed();
  console.log(pvp.address, "123123");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
