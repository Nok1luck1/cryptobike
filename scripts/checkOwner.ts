<<<<<<< HEAD
import { deploy } from "@openzeppelin/hardhat-upgrades/dist/utils";
import { ethers } from "hardhat";
const hre = require("hardhat");
import Market from "../artifacts/contracts/FactoryMarket.sol/FactoryMarket.json";
async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(deployer.address, "deployed address");
  const FactoryMarketContr = await ethers.getContractAt(
    Market.abi,
    "0xEAC681A16cd621f078732D93431D3F5572b6fa1e"
  );
  const account = await FactoryMarketContr.generateAccount(123);
  console.log(`Market address : ${account}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
=======
// import { deploy } from "@openzeppelin/hardhat-upgrades/dist/utils";
// import { ethers } from "hardhat";
// const hre = require("hardhat");
// import ERC721 from "../artifacts/@openzeppelin/contracts/token/ERC721/ERC721.sol/ERC721.json";
// async function main() {
//   const [deployer] = await ethers.getSigners();
//   console.log(deployer.address, "deployed address");
//   const FactoryMarketContr = await ethers.getContractFactory("FreeByke");

//   console.log(`Market address : ${market.address}`);
// }

// // We recommend this pattern to be able to use async/await everywhere
// // and properly handle errors.
// main().catch((error) => {
//   console.error(error);
//   process.exitCode = 1;
// });
>>>>>>> 531b888dd12c83034dacc7e23a8f7ed4ae8d4041
