// This is a script for deployment and automatically verification of the `contracts/LimitOrdersController.sol`

const { ethers, upgrades } = require("hardhat");

const Contract: string = "0xA91391e24691F1017b9Ae4f1c98c9A67716612c0";

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
  const NewContract = (await ethers.getContractFactory("MTBv2")).connect(
    deployer
  );
  await upgrades.upgradeProxy(Contract, NewContract);
  console.log("Upgrade is completed.");
}

// This pattern is recommended to be able to use async/await everywhere and properly handle errors
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
