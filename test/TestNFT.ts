import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { BigNumber } from "ethers";
import { expect } from "chai";

const { upgrades, ethers } = require("hardhat");
import Player from "../artifacts/contracts/Account721.sol/Account721.json";
//import { AccountFactory__factory } from "../typechain-types/factories/contracts/AccountFactory__factory";
//import Token from "../artifacts/contracts/test/ERC20.sol/TEST.json";
describe("Account Test", function () {
  async function deployOneYearLockFixture() {
    const [deployer, addr1, addr2] = await ethers.getSigners();
    console.log(deployer.address, "deployer address");
    const FactoryMarketContr = await ethers.getContractFactory(
      "FactoryMarketNonProx"
    );
    const market = await FactoryMarketContr.deploy();
    await market.deployed();
    console.log(`Market address : ${market.address}`);
    const Token = await ethers.getContractFactory("TEST");
    const token = await Token.deploy();
    await token.deployed();
    const ERC721 = await ethers.getContractFactory("TESTERC721");
    const nft = await ERC721.deploy();
    await nft.deployed();

    const NFT = await ethers.getContractFactory("BinanceRemaster");
    const initValue = ["hueta", "EAF", "pornhub.com/"];
    const nftRemaster = await upgrades.deployProxy(NFT, initValue, {
      initializer: "initialize",
      kind: "uups",
    });
    await nftRemaster.deployed();
    const value = BigNumber.from("1000000000000000");
    const value2 = BigNumber.from("1000000000000000000");

    const createAcc = await market
      .connect(deployer)
      .generateAccount(123123, [], []);

    const AddresAcc = await market.accountAddress(deployer.address);
    const hasOr =
      "0x0000000000000000000000000000000000000000000000000000000000000001";
    const Account = await ethers.getContractAt(Player.abi, AddresAcc);
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
      Account,
      AddresAcc,
    };
  }

  it("Creation Sell remaster on market", async function () {
    const { market, nftRemaster, deployer, token, hasOr, value2 } =
      await loadFixture(deployOneYearLockFixture);
    const mint = await nftRemaster.mint(deployer.address, 1);
    expect(await nftRemaster.balanceOf(deployer.address)).to.equal(1);
    const approve = await nftRemaster.approve(market.address, 1);
    const createOrder = await market.createOrder(
      0,
      nftRemaster.address,
      token.address,
      hasOr,
      "0x00",
      value2,
      1,
      1
    );
    const mustbe = [
      0,
      nftRemaster.address,
      token.address,
      deployer.address,
      BigNumber.from(1),
      BigNumber.from(1),
      value2,
      "0x00",
    ];
    expect(await market.OrderByHash(hasOr)).to.deep.equal(mustbe);
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
});
