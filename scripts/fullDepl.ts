import { deploy } from "@openzeppelin/hardhat-upgrades/dist/utils";
import { ethers, upgrades } from "hardhat";
const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(deployer.address, "deployed address");
  const zakhar = "0x5C5193544Fce3f8407668D451b20990303cc692a";
  const signer = "0xd62d87147a3dbf6ac5049ba0763773033280e9a9";
  const BinanceRemaster = await ethers.getContractFactory("Character");
  const items = await ethers.getContractFactory("BykeItems");
  const bykerent = await ethers.getContractFactory("BykeRentable");
  const factory = await ethers.getContractFactory("Factory");
  const freecolection = await ethers.getContractFactory("FreeCollection");
  const rentmarket = await ethers.getContractFactory("RentMarket");
  const initValue = ["hueta", "EAF", "pornhub.com/"];
  const BinanceRemaste = await upgrades.deployProxy(
    BinanceRemaster,
    initValue,
    {
      initializer: "initialize",
      kind: "uups",
    }
  );
  await BinanceRemaste.deployed();
  const Items = await items.deploy("pornhub.com/");
  await Items.deployed();
  const initvalue2 = [zakhar, "Byke", "MTByke", ""]; ////need to know it
  const BykeRentable = await upgrades.deployProxy(bykerent, initvalue2, {
    initializer: "initialize",
    kind: "uups",
  });
  await BykeRentable.deployed();

  const initvalue3 = [deployer.address];
  const RentMarket = await upgrades.deployProxy(rentmarket, initvalue3, {
    initializer: "initialize",
    kind: "uups",
  });
  await RentMarket.deployed();
  const role =
    "0x0000000000000000000000000000000000000000000000000000000000000000";

  const Free = await freecolection.deploy(BykeRentable.address, zakhar); //need url from back
  await Free.deployed();

  const Market = await factory.deploy(RentMarket.address, 30);
  await Market.deployed();
  console.log(Market.address, "Market");
  console.log(BinanceRemaste.address, "BinanceRemaste ");

  console.log(Items.address, "Items");
  console.log(BykeRentable.address, "BykeRentable");
  console.log(Free.address, "Free");
  console.log(RentMarket.address, "RENTMARKET");
  const giveRole1 = await BinanceRemaste.grantRole(role, zakhar);
  console.log("All done1");
  const giveRole2 = await Items.grantRole(role, zakhar);
  console.log("All done2");
  const giveRole3 = await BykeRentable.grantRole(role, zakhar);
  console.log("All done3");
  const giveRole4 = await Free.grantRole(role, zakhar);
  console.log("All done4");
  const giveRole5 = await RentMarket.grantRole(role, zakhar);
  console.log("All done5");
  const pvpvv2 = await ethers.getContractFactory("PvpV2");
  const PVP = await upgrades.deployProxy(pvpvv2, [zakhar, Items.address], {
    initializer: "initialize",
    kind: "uups",
  });
  await PVP.deployed();
  const signature = await ethers.getContractFactory("SignatureChecker");
  const Signature = await signature.deploy(
    Free.address,
    BykeRentable.address,
    Items.address,
    PVP.address,
    zakhar
  );
  console.log(PVP.address, "PVPv2");
  console.log(Signature.address, "Signature");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
