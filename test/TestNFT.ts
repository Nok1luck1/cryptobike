import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { BigNumber } from "ethers";
import { expect } from "chai";

const { upgrades, ethers } = require("hardhat");

describe("Byke remaster test", function () {
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
    const ERC721 = await ethers.getContractFactory("TESTERC721");
    const nft = await ERC721.deploy();
    await nft.deployed();

    const NFT = await ethers.getContractFactory("Character");
    const initValue = ["hueta", "EAF", "pornhub.com/"];
    const nftRemaster = await upgrades.deployProxy(NFT, initValue, {
      initializer: "initialize",
      kind: "uups",
    });
    await nftRemaster.deployed();
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

  it("Creation Sell remaster on market", async function () {
    const { market, nftRemaster, deployer, token, hasOr, value2 } =
      await loadFixture(deployOneYearLockFixture);
    const mint = await nftRemaster.mint(deployer.address, 1);
    expect(await nftRemaster.balanceOf(deployer.address)).to.equal(1);
    const approve = await nftRemaster.approve(market.address, 1);
    const createOrder = await market.createOrder(
      3,
      nftRemaster.address,
      token.address,
      hasOr,
      "0x00",
      value2,
      1,
      1
    );
    const mustbe = [
      3,
      nftRemaster.address,
      token.address,
      deployer.address,
      "0x00",
      BigNumber.from(1),
      BigNumber.from(1),
      value2,
    ];
    expect(await market.OrderByHash(hasOr)).to.deep.equal(mustbe);
  });
  it("Creation Sell remaster on market for ether", async function () {
    const { market, nftRemaster, deployer, token, hasOr, value2 } =
      await loadFixture(deployOneYearLockFixture);
    const mint = await nftRemaster.mint(deployer.address, 1);
    expect(await nftRemaster.balanceOf(deployer.address)).to.equal(1);
    const approve = await nftRemaster.approve(market.address, 1);
    const createOrder = await market.createOrder(
      3,
      nftRemaster.address,
      "0x0000000000000000000000000000000000000000",
      hasOr,
      "0x00",
      ethers.utils.parseUnits("1000000000000000000", "wei"),
      1,
      1
    );
    const mustbe = [
      3,
      nftRemaster.address,
      "0x0000000000000000000000000000000000000000",
      deployer.address,
      "0x00",
      BigNumber.from(1),
      BigNumber.from(1),
      value2,
    ];
    expect(await market.OrderByHash(hasOr)).to.deep.equal(mustbe);
  });
  it("Creation Sell remaster on market for ether and buy it", async function () {
    const { market, nftRemaster, deployer, token, hasOr, value2 } =
      await loadFixture(deployOneYearLockFixture);
    const mint = await nftRemaster.mint(deployer.address, 1);
    expect(await nftRemaster.balanceOf(deployer.address)).to.equal(1);
    const approve = await nftRemaster.approve(market.address, 1);
    const createOrder = await market.createOrder(
      3,
      nftRemaster.address,
      "0x0000000000000000000000000000000000000000",
      hasOr,
      "0x00",
      1,
      1,
      1
    );
    const mustbe = [
      3,
      nftRemaster.address,
      "0x0000000000000000000000000000000000000000",
      deployer.address,
      "0x00",
      BigNumber.from(1),
      BigNumber.from(1),
      BigNumber.from(1),
    ];
    const mustAFTER = [
      0,
      "0x0000000000000000000000000000000000000000",
      "0x0000000000000000000000000000000000000000",
      "0x0000000000000000000000000000000000000000",
      "0x",
      BigNumber.from(0),
      BigNumber.from(0),
      BigNumber.from(0),
    ];

    expect(await market.OrderByHash(hasOr)).to.deep.equal(mustbe);
    const buy = await market.buyFromOrder(hasOr, 1, deployer.address, {
      value: 1,
    });
    expect(await market.OrderByHash(hasOr)).to.deep.equal(mustAFTER);
  });
  it("Check uri storage", async function () {
    const { nftRemaster, deployer } = await loadFixture(
      deployOneYearLockFixture
    );
    const mint = await nftRemaster.mint(deployer.address, 1);
    expect(await nftRemaster.balanceOf(deployer.address)).to.equal(1);
    //const approve = await nftRemaster.approve(market.address, 1);
    expect(await nftRemaster.tokenURI(1)).to.equal("pornhub.com/1");
  });
  it("Check giving rent for 1", async function () {
    const { nftRemaster, deployer, addr1 } = await loadFixture(
      deployOneYearLockFixture
    );
    const mint = await nftRemaster.mint(deployer.address, 1);
    expect(await nftRemaster.balanceOf(deployer.address)).to.equal(1);
    //const approve = await nftRemaster.approve(addr1.address, 1);
    let expires = Math.floor(new Date().getTime() / 1000) + 1000;
    const stUSer = await nftRemaster.setUser(1, addr1.address, expires);
    expect(await nftRemaster.userOf(1)).to.equal(addr1.address);
  });
  it("Check should support interface for RENT", async function () {
    const { nftRemaster, deployer, addr1 } = await loadFixture(
      deployOneYearLockFixture
    );
    const mint = await nftRemaster.mint(deployer.address, 1);
    expect(await nftRemaster.balanceOf(deployer.address)).to.equal(1);
    //const approve = await nftRemaster.approve(addr1.address, 1);
    let expires = Math.floor(new Date().getTime() / 1000) + 1000;
    const stUSer = await nftRemaster.setUser(1, addr1.address, expires);
    expect(await nftRemaster.userOf(1)).to.equal(addr1.address);
    const interfaceID = "0xad092b5c";
    expect(await nftRemaster.supportsInterface(interfaceID)).to.equal(true);
  });
  it("Check mint with user signature", async function () {
    const { nftRemaster, deployer, addr1, token, value2 } = await loadFixture(
      deployOneYearLockFixture
    );
    const getTenMinsTimestamp = () => {
      const minutesToAdd = 10;
      const currentDate = new Date();
      const expiry = new Date(currentDate.getTime() + minutesToAdd * 60000);
      return Math.floor(expiry.getTime() / 1000);
    };
    const signerad = await nftRemaster.changeSigner(deployer.address);
    const time = getTenMinsTimestamp();
    const blance = await token.mint(deployer.address, value2);
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
  });
});
