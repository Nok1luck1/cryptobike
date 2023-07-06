// This is a script for deployment and automatically verification of the `contracts/LimitOrdersController.sol`

const { ethers, upgrades } = require("hardhat");

const Contract: string = "0x7a633b842D6bD1dF6c771d17b9cc410617092657";

async function main() {
  /*
   * Hardhat always runs the compile task when running scripts with its command line interface.
   *
   * If this script is run directly using `node` you may want to call compile manually
   * to make sure everything is compiled.
   */
  // await hre.run("compile");

  const [deployer] = await ethers.getSigners();

  // Deployment
  //set here new version contract
  const NewContract = (
    await ethers.getContractFactory("BykeRentableV2")
  ).connect(deployer);
  await upgrades.upgradeProxy(Contract, NewContract);
  console.log("Upgrade is completed.");
}

// This pattern is recommended to be able to use async/await everywhere and properly handle errors
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
