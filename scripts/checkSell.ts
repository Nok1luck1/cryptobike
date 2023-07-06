import { deploy } from "@openzeppelin/hardhat-upgrades/dist/utils";
import { ethers } from "hardhat";
import { BigNumber } from "ethers";
const hre = require("hardhat");
import Factory from "../artifacts/contracts/Factory.sol/Factory.json";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(deployer.address, "deployer address");

  const Factorycontract = await ethers.getContractAt(
    Factory.abi,
    "0x473DEB3ed298372026C656423fF5F08cf6186EDB"
  );
  const secsec = await Factorycontract.sellAcc(
    {
      target: "0x3D1a24dc1Bf6f6BED9cD68Ad368f2be1cF380688",
      seller: deployer.address,
      paymentT: "0xF28b5b9995C052a0e4EC1b848EafA6D3b29a7724",
      accountID: 123,
      price: BigNumber.from("100000000000000"),
      addr721: [
        "0x69f967a85E5BA2fdec84D600b624522875DB8f64",
        "0x69f967a85E5BA2fdec84D600b624522875DB8f64",
      ],
      addr1155: [],
      tokens721: [1, 2],
      tokens1155: [],
      amounts: [],
    },
    "0x0000000000000000000000000000000000000000000000000000000000000001"
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
