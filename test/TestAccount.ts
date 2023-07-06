import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { BigNumber } from "ethers";
import { expect } from "chai";

const { upgrades, ethers } = require("hardhat");
import Player from "../artifacts/contracts/Account721.sol/Account721.json";
describe("Account Test", function () {
  async function deployOneYearLockFixture() {
    const [deployer, addr1, addr2] = await ethers.getSigners();
    const FactoryMarketContr = await ethers.getContractFactory("RentMarket");
    const init = [deployer.address];
    const market = await upgrades.deployProxy(FactoryMarketContr, init, {
      initializer: "initialize",
      kind: "uups",
    });
    await market.deployed();
    const factory = await ethers.getContractFactory("Factory");

    const Factory = await factory.deploy(market.address, 10);
    await Factory.deployed();

    const Token = await ethers.getContractFactory("TEST");
    const token = await Token.deploy();
    await token.deployed();
    const ERC721 = await ethers.getContractFactory("TESTERC721");
    const nft = await ERC721.deploy();
    await nft.deployed();
    const ERC1155 = await ethers.getContractFactory("BykeItems");

    const collect = await upgrades.deployProxy(ERC1155, ["pornhub.com/"], {
      initializer: "initialize",
      kind: "uups",
    });
    await collect.deployed();
    const value = BigNumber.from("1000000000000000");
    const value2 = BigNumber.from("1000000000000000000");
    const pvpv2 = await ethers.getContractFactory("PvpV2");
    const init2 = [deployer.address, collect.address];
    const PVP = await upgrades.deployProxy(pvpv2, init2, {
      initializer: "initialize",
      kind: "uups",
    });
    await PVP.deployed();

    const createAcc = await Factory.connect(deployer).generateAccount({
      erc1155: "0x0000000000000000000000000000000000000000",
      accountId: 123123,
      addrERC721: [],
      id721: [],
      ids: [],
      amounts: [],
    });

    const AddresAcc = await Factory.accountAddress(deployer.address);

    const Account = await ethers.getContractAt(Player.abi, AddresAcc);
    return {
      PVP,
      market,
      Factory,
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
      await expect(await nft.balanceOf(Account.address)).to.equal(1);
    });
    it("Should accept ERC721 and transfer Out", async function () {
      const { deployer, AddresAcc, Account, nft } = await loadFixture(
        deployOneYearLockFixture
      );

      const balanceBefore = await nft.balanceOf(deployer.address);

      const approveNFT = await nft.connect(deployer).approve(AddresAcc, 1);

      const allowance = await nft.connect(deployer).getApproved(1);

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

      const mint123 = await collect.mintAdmin(0, 10, deployer.address);
      const approveNFT = await collect
        .connect(deployer)
        .setApprovalForAll(AddresAcc, true);

      const allowance = await collect
        .connect(deployer)
        .isApprovedForAll(deployer.address, AddresAcc);
      const balance = await collect.balanceOf(deployer.address, 1);
      const transfer = await collect
        .connect(deployer)
        .safeTransferFrom(deployer.address, AddresAcc, 1, 10, "0x00");

      expect(await collect.balanceOf(AddresAcc, 1)).to.equal(10);
    });
    it("Should accept ERC1155 and transfer from Account", async function () {
      const { deployer, AddresAcc, collect, Account } = await loadFixture(
        deployOneYearLockFixture
      );
      const mint123 = await collect.mintAdmin(0, 10, deployer.address);
      const balance = await collect.balanceOf(deployer.address, 1);
      const approveNFT = await collect
        .connect(deployer)
        .setApprovalForAll(AddresAcc, true);

      const allowance = await collect
        .connect(deployer)
        .isApprovedForAll(deployer.address, AddresAcc);
      const transfer = await collect
        .connect(deployer)
        .safeTransferFrom(deployer.address, AddresAcc, 1, 10, "0x00");

      expect(await collect.balanceOf(AddresAcc, 1)).to.equal(10);

      const transferOut = await Account.witdhraw1155(
        collect.address,
        deployer.address,
        1,
        10,
        "0x00"
      );
      expect(await collect.balanceOf(deployer.address, 1)).to.equal(balance);
    });
    it("Should create Order with 1155 from account", async function () {
      const { deployer, AddresAcc, collect, Account, token, market } =
        await loadFixture(deployOneYearLockFixture);
      const mint123 = await collect.mintAdmin(0, 10, deployer.address);
      const balance = await collect.balanceOf(deployer.address, 0);
      const approveNFT = await collect
        .connect(deployer)
        .setApprovalForAll(AddresAcc, true);

      const allowance = await collect
        .connect(deployer)
        .isApprovedForAll(deployer.address, AddresAcc);

      const transfer = await collect
        .connect(deployer)
        .safeTransferFrom(deployer.address, AddresAcc, 1, 10, "0x00");

      expect(await collect.balanceOf(AddresAcc, 1)).to.equal(10);
      const hasOr =
        "0x0000000000000000000000000000000000000000000000000000000000000001";

      const createOrder = await Account.sellItem(
        4,
        collect.address,
        token.address,
        hasOr,
        "0x00",
        1000,
        1,
        10
      );
      const ord = await market.OrderByHash(hasOr);
      expect(ord[1].toLowerCase()).to.equal(collect.address.toLowerCase());
    });
    it("Should create Order with 721 from account", async function () {
      const { deployer, AddresAcc, nft, Account, token, market } =
        await loadFixture(deployOneYearLockFixture);

      const balance = await nft.balanceOf(deployer.address);
      const approveNFT = await nft.connect(deployer).approve(AddresAcc, 1);
      const allowance = await nft.connect(deployer).getApproved(1);
      const transfer = await nft
        .connect(deployer)
        .transferFrom(deployer.address, AddresAcc, 1);

      expect(await nft.balanceOf(AddresAcc)).to.equal(1);
      const hasOr =
        "0x0000000000000000000000000000000000000000000000000000000000000001";

      const createOrder = await Account.sellItem(
        3,
        nft.address,
        token.address,
        hasOr,
        "0x00",
        1000,
        1,
        1
      );
      const ord = await market.OrderByHash(hasOr);
      expect(ord[1].toLowerCase()).to.equal(nft.address.toLowerCase());
    });
    it("Should sell account", async function () {
      const {
        deployer,
        Factory,
        AddresAcc,
        nft,
        Account,
        collect,
        token,
        value2,
        market,
      } = await loadFixture(deployOneYearLockFixture);

      const balance = await nft.balanceOf(deployer.address);
      const mint = await nft.mint(AddresAcc, 0);

      const minCol = await collect.mintAdmin(1, 1000, AddresAcc);

      const allowance = await nft.connect(deployer).getApproved(1);
      const transfer = await nft
        .connect(deployer)
        .transferFrom(deployer.address, AddresAcc, 1);

      expect(await nft.balanceOf(AddresAcc)).to.equal(2);
      const hasOr =
        "0x0000000000000000000000000000000000000000000000000000000000000001";

      const orderSell = {
        target: AddresAcc,
        seller: deployer.address,
        paymentT: token.address,
        accountID: 123123,
        price: value2,
        addr721: [nft.address, nft.address],
        addr1155: [collect.address, collect.address],
        tokens721: [0, 1],
        tokens1155: [0, 1],
        amounts: [10, 100],
      };
      const sell = await Factory.sellAcc(orderSell, hasOr);
      const order = await Factory.orderAccounts(hasOr);
      expect(order.target).to.equal(AddresAcc);
    });
    it("Should sell account and buy from user without account", async function () {
      const {
        addr1,
        deployer,
        Factory,
        AddresAcc,
        nft,
        Account,
        collect,
        token,
        value2,
        market,
      } = await loadFixture(deployOneYearLockFixture);

      const balance = await nft.balanceOf(deployer.address);
      const mint = await nft.mint(AddresAcc, 2);
      const minCol = await collect.mintAdmin(1, 1000, AddresAcc);
      const approveNFT = await nft.connect(deployer).approve(AddresAcc, 1);
      const allowance = await nft.connect(deployer).getApproved(1);
      const transfer = await nft
        .connect(deployer)
        .transferFrom(deployer.address, AddresAcc, 1);

      expect(await nft.balanceOf(AddresAcc)).to.equal(2);
      const hasOr =
        "0x0000000000000000000000000000000000000000000000000000000000000001";

      const orderSell = {
        target: AddresAcc,
        seller: deployer.address,
        paymentT: token.address,
        accountID: 123123,
        price: value2,
        addr721: [nft.address, nft.address],
        addr1155: [collect.address, collect.address],
        tokens721: [1, 2],
        tokens1155: [0, 1],
        amounts: [10, 100],
      };
      const sell = await Factory.sellAcc(orderSell, hasOr);
      const order = await Factory.orderAccounts(hasOr);
      expect(order.target).to.equal(AddresAcc);

      const tokenMint = await token
        .connect(addr1)
        .mint(addr1.address, BigNumber.from("100000000000000000000000"));
      const approveToken = await token
        .connect(addr1)
        .approve(Factory.address, value2);

      const currentOwner = await Account.currentowner();
      expect(await token.allowance(addr1.address, Factory.address)).to.equal(
        value2
      );
      const buy = await Factory.connect(addr1).buyAcc(hasOr, addr1.address);
      expect(await Factory.accountAddress(addr1.address)).to.equal(AddresAcc);
    });
    it("Should sell account and buy from user with account", async function () {
      const {
        addr1,
        deployer,
        Factory,
        AddresAcc,
        nft,
        Account,
        collect,
        token,
        value2,
        market,
      } = await loadFixture(deployOneYearLockFixture);

      const balance = await nft.balanceOf(deployer.address);
      const mint = await nft.mint(AddresAcc, 2);
      const minCol = await collect.mintAdmin(1, 1000, AddresAcc);
      const minCol1 = await collect.mintAdmin(0, 1000, AddresAcc);
      const approveNFT = await nft.connect(deployer).approve(AddresAcc, 1);
      const allowance = await nft.connect(deployer).getApproved(1);
      const transfer = await nft
        .connect(deployer)
        .transferFrom(deployer.address, AddresAcc, 1);

      expect(await nft.balanceOf(AddresAcc)).to.equal(2);
      const hasOr =
        "0x0000000000000000000000000000000000000000000000000000000000000001";

      const orderSell = {
        target: AddresAcc,
        seller: deployer.address,
        paymentT: token.address,
        accountID: 123123,
        price: value2,
        addr721: [nft.address, nft.address],
        addr1155: [collect.address, collect.address],
        tokens721: [1, 2],
        tokens1155: [1, 2],
        amounts: [100, 100],
      };
      const balance123 = await collect.balanceOf(AddresAcc, 0);
      const balance1234 = await collect.balanceOf(AddresAcc, 1);
      const sell = await Factory.sellAcc(orderSell, hasOr);
      const order = await Factory.orderAccounts(hasOr);
      expect(order.target).to.equal(AddresAcc);

      const tokenMint = await token
        .connect(addr1)
        .mint(addr1.address, BigNumber.from("100000000000000000000000"));
      const approveToken = await token
        .connect(addr1)
        .approve(Factory.address, value2);

      const currentOwner = await Account.currentowner();

      expect(await token.allowance(addr1.address, Factory.address)).to.equal(
        value2
      );

      const createAcc = await Factory.connect(addr1).generateAccount({
        erc1155: "0x0000000000000000000000000000000000000000",
        accountId: 123123,
        addrERC721: [],
        id721: [],
        ids: [],
        amounts: [],
      });
      const userAss = await Factory.accountAddress(addr1.address);
      const buy = await Factory.connect(addr1).buyAcc(hasOr, addr1.address);
      expect(await Factory.accountAddress(addr1.address)).to.equal(userAss);
    });
  });
});
