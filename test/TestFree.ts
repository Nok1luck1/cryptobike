import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { BigNumber } from "ethers";
import { expect } from "chai";

//const Web3 = require("web3");
const { upgrades, ethers } = require("hardhat");
//const sign = require("./sign");

describe("Freee Test", function () {
  async function deployOneYearLockFixture() {
    const [deployer, addr1, addr2] = await ethers.getSigners();

    const FactoryMarketContr = await ethers.getContractFactory("RentMarket");
    const init = [deployer.address];
    const market = await upgrades.deployProxy(FactoryMarketContr, init, {
      initializer: "initialize",
      kind: "uups",
    });
    await market.deployed();

    const Token = await ethers.getContractFactory("TEST");
    const token = await Token.deploy();
    await token.deployed();

    const NFT = await ethers.getContractFactory("BykeRentable");
    const initValue = [deployer.address, "hueta", "EAF", "pornhub.com/"];
    const nftRemaster = await upgrades.deployProxy(NFT, initValue, {
      initializer: "initialize",
      kind: "uups",
    });
    await nftRemaster.deployed();
    const ERC721 = await ethers.getContractFactory("FreeCollection");
    const nft = await ERC721.deploy(nftRemaster.address, deployer.address);
    await nft.deployed();
    const value = BigNumber.from("1000000000000000");
    const value2 = BigNumber.from("1000000000000000000");

    const hasOr =
      "0x0000000000000000000000000000000000000000000000000000000000000001";

    return {
      hasOr,
      nftRemaster,
      market,
      deployer,
      addr1,
      addr2,
      token,
      nft,
      value2,
    };
  }

  it("Check should fail in second freeemint", async function () {
    const { nft, deployer, nftRemaster, addr1 } = await loadFixture(
      deployOneYearLockFixture
    );
    const ffreeemint = await nft.freeMint();
    expect(nft.freeMint()).to.be.revertedWith("Cant mint more");
  });
  it("Should burn and mint", async function () {
    const { nft, deployer, nftRemaster, addr1 } = await loadFixture(
      deployOneYearLockFixture
    );
    const getTenMinsTimestamp = () => {
      const minutesToAdd = 10;
      const currentDate = new Date();
      const expiry = new Date(currentDate.getTime() + minutesToAdd * 60000);
      return Math.floor(expiry.getTime() / 1000);
    };
    const mint = await nft.freeMint();
    const qwedqw = await nftRemaster.grantRole(
      "0x8f38086728c25feaf5a0873d42f94e30d6fcd000d742dbdb55a594c5c83ac04a",
      nft.address
    );

    const time = getTenMinsTimestamp();

    const data1 = await nft.getMessageHash({
      account: deployer.address,
      burnID: 0,
      mintID: 2,
      expiry: time,
    });
    const hash = await nft.getEthSignedMessageHash(data1);
    let signature = await deployer.signMessage(ethers.utils.arrayify(data1));

    const burnm = await nft.burnAndMint(
      {
        account: deployer.address,
        burnID: 0,
        mintID: 2,
        expiry: time,
      },
      signature
    );
    expect(await nftRemaster.balanceOf(deployer.address)).to.equal(1);
  });
  it("Should burn and mint withOut free nft", async function () {
    const { nft, deployer, nftRemaster, addr1 } = await loadFixture(
      deployOneYearLockFixture
    );
    const getTenMinsTimestamp = () => {
      const minutesToAdd = 10;
      const currentDate = new Date();
      const expiry = new Date(currentDate.getTime() + minutesToAdd * 60000);
      return Math.floor(expiry.getTime() / 1000);
    };
    const mint = await nftRemaster.mint(deployer.address, 1);
    const qwedqw = await nftRemaster.grantRole(
      "0x8f38086728c25feaf5a0873d42f94e30d6fcd000d742dbdb55a594c5c83ac04a",
      nft.address
    );

    const time = getTenMinsTimestamp();

    const data1 = await nftRemaster.getMessageHash(
      deployer.address,
      1,
      2,
      time
    );
    const hash = await nftRemaster.getEthSignedMessageHash(data1);
    let signature = await deployer.signMessage(ethers.utils.arrayify(data1));

    const burnm = await nftRemaster.burnAndMint(
      deployer.address,
      1,
      2,
      time,

      signature
    );
    expect(await nftRemaster.balanceOf(deployer.address)).to.equal(1);
  });
  it("Should mint with signature check", async function () {
    const { nft, deployer, nftRemaster, addr1 } = await loadFixture(
      deployOneYearLockFixture
    );
    const getTenMinsTimestamp = () => {
      const minutesToAdd = 10;
      const currentDate = new Date();
      const expiry = new Date(currentDate.getTime() + minutesToAdd * 60000);
      return Math.floor(expiry.getTime() / 1000);
    };
    //const mint = await nftRemaster.mint(deployer.address, 0);
    const qwedqw = await nftRemaster.grantRole(
      "0x8f38086728c25feaf5a0873d42f94e30d6fcd000d742dbdb55a594c5c83ac04a",
      nft.address
    );

    const time = getTenMinsTimestamp();

    const data1 = await nftRemaster.getMessageHash1(
      deployer.address,
      deployer.address,
      2,
      time
    );
    const hash = await nftRemaster.getEthSignedMessageHash(data1);
    let signature = await deployer.signMessage(ethers.utils.arrayify(data1));
    const burnm = await nftRemaster.mintFor(
      deployer.address,
      deployer.address,
      2,
      time,

      signature
    );
    expect(await nftRemaster.balanceOf(deployer.address)).to.equal(1);
  });
});
