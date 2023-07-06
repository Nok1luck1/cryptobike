import { ethers, upgrades } from "hardhat";
const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(deployer.address, "deployed address");
  const items = await ethers.getContractFactory("BykeItems");
  const ITEMS = await upgrades.deployProxy(items, ["pornhub.com/"], {
    initializer: "initialize",
    kind: "uups",
  });
  console.log(`Market address : ${ITEMS.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
