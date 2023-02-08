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
    const ERC1155 = await ethers.getContractFactory("TESTERC1155");
    const collect = await ERC1155.deploy();
    await collect.deployed();
    const value = BigNumber.from("1000000000000000");
    const value2 = BigNumber.from("1000000000000000000");

    const createAcc = await market
      .connect(deployer)
      .generateAccount(123123, [], []);

    const AddresAcc = await market.accountAddress(deployer.address);

    const Account = await ethers.getContractAt(Player.abi, AddresAcc);
    return {
      market,
      deployer,
      addr1,
      addr2,
      token,
      nft,
      collect,
      value2,
      Account,
      AddresAcc,
    };
  }

  describe("Creation Account", function () {
    it("Should accept ERC721", async function () {
      const { deployer, AddresAcc, nft, Account } = await loadFixture(
        deployOneYearLockFixture
      );
      const balance = await nft.balanceOf(deployer.address);
      const approveNFT = await nft.connect(deployer).approve(AddresAcc, 1);
      const allowance = await nft.connect(deployer).getApproved(1);
      const transfer = await nft
        .connect(deployer)
        .transferFrom(deployer.address, AddresAcc, 1);
      expect(await nft.balanceOf(Account.address)).to.equal(1);
    });
    it("Should accept ERC721 and transfer Out", async function () {
      const { deployer, AddresAcc, Account, nft } = await loadFixture(
        deployOneYearLockFixture
      );

      const balanceBefore = await nft.balanceOf(deployer.address);

      const approveNFT = await nft.connect(deployer).approve(AddresAcc, 1);

      const allowance = await nft.connect(deployer).getApproved(1);
      console.log(allowance);
      const transfer = await nft
        .connect(deployer)
        .transferFrom(deployer.address, AddresAcc, 1);

      expect(await nft.balanceOf(AddresAcc)).to.equal(1);
      const transferOut = await Account.connect(deployer).withdraw721(
        nft.address,
        deployer.address,
        1
      );
      expect(await nft.balanceOf(deployer.address)).to.equal(balanceBefore);
    });
    it("Should accept ERC1155", async function () {
      const { deployer, AddresAcc, collect } = await loadFixture(
        deployOneYearLockFixture
      );

      const balance = await collect.balanceOf(deployer.address, 0);

      const approveNFT = await collect
        .connect(deployer)
        .setApprovalForAll(AddresAcc, true);

      const allowance = await collect
        .connect(deployer)
        .isApprovedForAll(deployer.address, AddresAcc);
      console.log(allowance);
      const transfer = await collect
        .connect(deployer)
        .safeTransferFrom(deployer.address, AddresAcc, 0, 10, "0x00");

      expect(await collect.balanceOf(AddresAcc, 0)).to.equal(10);
    });
    it("Should accept ERC1155 and transfer from Account", async function () {
      const { deployer, AddresAcc, collect, Account } = await loadFixture(
        deployOneYearLockFixture
      );

      const balance = await collect.balanceOf(deployer.address, 0);
      const approveNFT = await collect
        .connect(deployer)
        .setApprovalForAll(AddresAcc, true);

      const allowance = await collect
        .connect(deployer)
        .isApprovedForAll(deployer.address, AddresAcc);
      console.log(allowance);
      const transfer = await collect
        .connect(deployer)
        .safeTransferFrom(deployer.address, AddresAcc, 0, 10, "0x00");

      expect(await collect.balanceOf(AddresAcc, 0)).to.equal(10);

      const transferOut = await Account.witdhraw1155(
        collect.address,
        deployer.address,
        0,
        10,
        "0x00"
      );
      expect(await collect.balanceOf(deployer.address, 0)).to.equal(balance);
    });
    it("Should create Order from account", async function () {
      const { deployer, AddresAcc, collect, Account, token, market } =
        await loadFixture(deployOneYearLockFixture);

      const balance = await collect.balanceOf(deployer.address, 0);
      const approveNFT = await collect
        .connect(deployer)
        .setApprovalForAll(AddresAcc, true);

      const allowance = await collect
        .connect(deployer)
        .isApprovedForAll(deployer.address, AddresAcc);

      const transfer = await collect
        .connect(deployer)
        .safeTransferFrom(deployer.address, AddresAcc, 0, 10, "0x00");

      expect(await collect.balanceOf(AddresAcc, 0)).to.equal(10);
      const hasOr =
        "0x0000000000000000000000000000000000000000000000000000000000000001";

      const createOrder = await Account.sellItem(
        1,
        collect.address,
        token.address,
        hasOr,
        "0x00",
        1000,
        0,
        10
      );
      const ord = await market.OrderByHash(hasOr);
      expect(ord[1].toLowerCase()).to.equal(collect.address.toLowerCase());
    });
  });
});
