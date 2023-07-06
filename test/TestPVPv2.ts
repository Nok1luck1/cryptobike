import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { BigNumber } from "ethers";
import { expect } from "chai";

//const Web3 = require("web3");
const { upgrades, ethers } = require("hardhat");
//const sign = require("./sign");

describe(" Test PVP v2", function () {
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
    const jnjn = await ethers.getContractFactory("TESTERC1155");
    const ERC15 = await jnjn.deploy();
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
    const items = await ethers.getContractFactory("BykeItems");
    const ITEMS = await upgrades.deployProxy(items, ["pornhub.com/"], {
      initializer: "initialize",
      kind: "uups",
    });
    const value = BigNumber.from("1000000000000000");
    const value2 = BigNumber.from("1000000000000000000");
    const pvpv2 = await ethers.getContractFactory("PvpV2");
    const init2 = [deployer.address, ERC15.address];
    const PVP = await upgrades.deployProxy(pvpv2, init2, {
      initializer: "initialize",
      kind: "uups",
    });
    await PVP.deployed();
    const TOKENcontr = await ethers.getContractFactory("MTCB");
    const initValue1 = [deployer.address];
    const token1 = await upgrades.deployProxy(TOKENcontr, initValue1, {
      initializer: "initialize",
      kind: "uups",
    });
    await token.deployed();
    const hasOr =
      "0x0000000000000000000000000000000000000000000000000000000000000001";

    return {
      ERC15,
      ITEMS,
      PVP,
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

  it("Should enter and withdraw throw signature", async function () {
    const { nft, deployer, nftRemaster, ERC15, PVP } = await loadFixture(
      deployOneYearLockFixture
    );
    const getTenMinsTimestamp = () => {
      const minutesToAdd = 10;
      const currentDate = new Date();
      const expiry = new Date(currentDate.getTime() + minutesToAdd * 60000);
      return Math.floor(expiry.getTime() / 1000);
    };
    const qwedqw = await nftRemaster.grantRole(
      "0x8f38086728c25feaf5a0873d42f94e30d6fcd000d742dbdb55a594c5c83ac04a",
      nft.address
    );
    const mint12 = await nftRemaster.mint(deployer.address, 3);
    const mint13 = await nftRemaster.mint(deployer.address, 4);
    const time = getTenMinsTimestamp();
    const approve1 = await nftRemaster.approve(PVP.address, 1);
    const approve2 = await nftRemaster.approve(PVP.address, 2);
    const approve3 = await ERC15.setApprovalForAll(PVP.address, true);

    const data1 = {
      sender: deployer.address,
      receiver: deployer.address,
      expirationDate: time,
      erc721: [nftRemaster.address, nftRemaster.address],
      id721: [1, 2],
      itemsId: [0],
      itemsAmount: [500],
    };
    const enter = await PVP.depositItems(data1);
    expect(await nftRemaster.balanceOf(PVP.address)).to.equal(2);
    const hash = await PVP.getMessageHash(data1);
    const hash2 = await PVP.getEthSignedMessageHash(hash);
    const signature = await deployer.signMessage(ethers.utils.arrayify(hash));
    const withdraw = await PVP.withdraw(data1, signature);
    expect(await nftRemaster.balanceOf(deployer.address)).to.equal(2);
  });
  it("Should check token uri", async function () {
    const { nft, deployer, nftRemaster, ITEMS, ERC15, PVP } = await loadFixture(
      deployOneYearLockFixture
    );
    const getTenMinsTimestamp = () => {
      const minutesToAdd = 10;
      const currentDate = new Date();
      const expiry = new Date(currentDate.getTime() + minutesToAdd * 60000);
      return Math.floor(expiry.getTime() / 1000);
    };
    const qwedqw = await nftRemaster.grantRole(
      "0x8f38086728c25feaf5a0873d42f94e30d6fcd000d742dbdb55a594c5c83ac04a",
      nft.address
    );
    const mint13 = await nftRemaster.mint(deployer.address, 4);
    const url = await nftRemaster.tokenURI(1);
    const mint1 = await ITEMS.mintAdmin(123123, 1, deployer.address);
    const mint2 = await ITEMS.mintAdmin(123123434, 1, deployer.address);
    const url1 = await ITEMS.uri(1);
  });
  it("Should check mint BykeItems for token with signature", async function () {
    const { nft, deployer, nftRemaster, ITEMS, ERC15, PVP, value2, token } =
      await loadFixture(deployOneYearLockFixture);
    const getTenMinsTimestamp = () => {
      const minutesToAdd = 10;
      const currentDate = new Date();
      const expiry = new Date(currentDate.getTime() + minutesToAdd * 60000);
      return Math.floor(expiry.getTime() / 1000);
    };
    const qwedqw = await nftRemaster.grantRole(
      "0x8f38086728c25feaf5a0873d42f94e30d6fcd000d742dbdb55a594c5c83ac04a",
      nft.address
    );
    const signerad = await ITEMS.changeSigner(deployer.address);
    const time = getTenMinsTimestamp();
    const blance = await token.mint(deployer.address, value2);
    console.log(await token.balanceOf(deployer.address), "123123");
    const approve = await token.approve(nftRemaster.address, value2);
    const data1 = await nftRemaster.getMessageHashBuy(
      deployer.address,
      token.address,
      1,
      value2,
      time
    );
    const hash = await nftRemaster.getEthSignedMessageHash(data1);
    let signature = await deployer.signMessage(ethers.utils.arrayify(data1));
    const burnm = await nftRemaster.buyNewNFT(
      deployer.address,
      token.address,
      1,
      value2,
      time,
      signature
    );
    expect(await nftRemaster.balanceOf(deployer.address)).to.equal(1);
    console.log(await token.balanceOf(deployer.address), "123123sdvd");
  });
});
