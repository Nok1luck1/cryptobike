import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { BigNumber } from "ethers";
import { expect } from "chai";
const helpers = require("@nomicfoundation/hardhat-network-helpers");

const { upgrades, ethers } = require("hardhat");

describe("Marketplace testing", function () {
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
    const ERC1155 = await ethers.getContractFactory("BykeItems");
    const collect = await upgrades.deployProxy(ERC1155, ["pornhub.com/"], {
      initializer: "initialize",
      kind: "uups",
    });
    await collect.deployed();

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
      market,
      deployer,
      addr1,
      addr2,
      token,
      nft,
      collect,
      value2,
      nftRemaster,
      hasOr,
    };
  }

  describe("Creation Account", function () {
    it("Should transfer token from marketplace", async function () {
      const { market, deployer, token } = await loadFixture(
        deployOneYearLockFixture
      );

      const approve = await token
        .connect(deployer)
        .approve(market.address, 1000000000000);
      await approve.wait();

      const tranferMarket = await token
        .connect(deployer)
        .transfer(market.address, 10000000);

      expect(await token.balanceOf(market.address)).to.equal(10000000);
      expect(
        await market.connect(deployer).withdrawFee(token.address, 10000000)
      )
        .to.emit(market, "Withdraw")
        .withArgs(deployer.address, token.address, 10000000);
    });

    it("Should creat order with ERC721 token", async function () {
      const { market, deployer, token, nft } = await loadFixture(
        deployOneYearLockFixture
      );
      const approveNFT = await nft.connect(deployer).approve(market.address, 1);

      const allowance = await nft.connect(deployer).getApproved(1);
      const hasOr =
        "0x0000000000000000000000000000000000000000000000000000000000000001";
      expect(
        await market.createOrder(
          0,
          nft.address,
          token.address,
          hasOr,
          "0x00",
          BigNumber.from("1000000000000000"),
          1,
          1
        )
      )
        .to.emit(market, "CreatedOrder")
        .withArgs(nft.address, deployer.address, hasOr, 0);
    });
    it("Should creat order with ERC1155 token", async function () {
      const { market, deployer, token, collect } = await loadFixture(
        deployOneYearLockFixture
      );
      const approveNFT = await collect
        .connect(deployer)
        .setApprovalForAll(market.address, true);

      const allowance = await collect
        .connect(deployer)
        .isApprovedForAll(deployer.address, market.address);
      expect(allowance).to.equal(true);
      const hasOr =
        "0x0000000000000000000000000000000000000000000000000000000000000002";
      expect(
        await market.createOrder(
          1,
          collect.address,
          token.address,
          hasOr,
          "0x00",
          BigNumber.from("1000000000000000"),
          0,
          100
        )
      )
        .to.emit(market, "CreatedOrder")
        .withArgs(collect.address, deployer.address, hasOr, 1);
    });

    it("Should creat order with ERC721 token and Sell to another user", async function () {
      const { market, deployer, token, nft, addr2, value2 } = await loadFixture(
        deployOneYearLockFixture
      );
      const approveNFT = await nft.connect(deployer).approve(market.address, 1);

      const allowance = await nft.connect(deployer).getApproved(1);
      const hasOr =
        "0x0000000000000000000000000000000000000000000000000000000000000001";
      expect(
        await market.createOrder(
          0,
          nft.address,
          token.address,
          hasOr,
          "0x00",
          BigNumber.from("1000000000000000"),
          1,
          1
        )
      )
        .to.emit(market, "CreatedOrder")
        .withArgs(nft.address, deployer.address, hasOr, 0);
      const mintAcc2 = await token.connect(addr2).mint(addr2.address, value2);
      const approveAcc2 = await token
        .connect(addr2)
        .approve(market.address, value2);
      const checkAllowance = await token.allowance(
        addr2.address,
        market.address
      );
      const balance = await token.balanceOf(addr2.address);
      expect(await market.connect(addr2).buyFromOrder(hasOr, 1, addr2.address))
        .to.emit(market, "BuyInOrder")
        .withArgs(nft.address, addr2.address, hasOr, 0);
    });
    it("Creation remaster rent order on market", async function () {
      const { market, nftRemaster, deployer, token, hasOr, value2, collect } =
        await loadFixture(deployOneYearLockFixture);
      const mintnft = await nftRemaster.mint(deployer.address, 0);
      const mintcol = await collect.mintAdmin(1, 1, deployer.address);
      const mintcol2 = await collect.mintAdmin(2, 1, deployer.address);
      const approv = await collect.setApprovalForAll(market.address, true);
      const approvenft = await nftRemaster.approve(market.address, 1);
      const orderValue = {
        status: 0,
        creator: deployer.address,
        renter: "0x0000000000000000000000000000000000000000",
        paymentToken: token.address,
        tokenTarget: nftRemaster.address,
        items: collect.address,
        data: "0x00",
        tokenId: 1,
        pricePerHour: value2,
        maxDuration: 1,
        expirationTime: 0,
        itemsIDs: [1, 2],
        amounts: [1, 1],
      };
      const createOrder = await market.putOnRent(orderValue, hasOr);
      const time = await ethers.provider.getBlockNumber();
      const wsevwev = await market.orders(hasOr);
      //expect(wsevwev[8]).to.equal(time + 3600);
    });
    it("Get rent on market", async function () {
      const {
        market,
        nftRemaster,
        deployer,
        addr1,
        token,
        hasOr,
        value2,
        collect,
      } = await loadFixture(deployOneYearLockFixture);
      const mintnft = await nftRemaster.mint(deployer.address, 0);
      const approvenft = await nftRemaster.approve(market.address, 1);
      const mintcol = await collect.mintAdmin(1, 1, deployer.address);
      const mintcol2 = await collect.mintAdmin(2, 1, deployer.address);
      const approv = await collect.setApprovalForAll(market.address, true);
      const approvenft1 = await nftRemaster.approve(market.address, 1);
      const time = await ethers.provider.getBlockNumber();
      const orderValue = {
        status: 0,
        creator: deployer.address,
        renter: "0x0000000000000000000000000000000000000000",
        paymentToken: token.address,
        tokenTarget: nftRemaster.address,
        items: collect.address,
        data: "0x00",
        tokenId: 1,
        pricePerHour: 1000000,
        maxDuration: 12,
        expirationTime: 0,
        itemsIDs: [1, 2],
        amounts: [1, 1],
      };
      const createOrder = await market.putOnRent(orderValue, hasOr);

      const wsevwev = await market.orders(hasOr);

      expect(wsevwev[10]).to.equal(0);
      const mintToken = await token.mint(addr1.address, value2);

      const approveT = await token
        .connect(addr1)
        .approve(market.address, value2);
      //const time = await ethers.provider.getBlockNumber();
      const timeEDn = time + 12 * 3600;
      const getRent = await market.connect(addr1).rent(hasOr, 12);
      expect(getRent)
        .to.emit(market, "RentedItem")
        .withArgs(
          deployer.address,
          addr1.address,
          timeEDn,
          nftRemaster.address
        );
    });
    it("Get rent on market after ending previous rent period", async function () {
      const {
        market,
        nftRemaster,
        deployer,
        addr1,
        addr2,
        token,
        hasOr,
        value2,
        collect,
      } = await loadFixture(deployOneYearLockFixture);
      const mintnft = await nftRemaster.mint(deployer.address, 0);
      const approvenft = await nftRemaster.approve(market.address, 1);
      const mintcol = await collect.mintAdmin(1, 1, deployer.address);
      const mintcol2 = await collect.mintAdmin(2, 1, deployer.address);
      const approv = await collect.setApprovalForAll(market.address, true);
      const orderValue = {
        status: 0,
        creator: deployer.address,
        renter: "0x0000000000000000000000000000000000000000",
        paymentToken: token.address,
        tokenTarget: nftRemaster.address,
        items: collect.address,
        data: "0x00",
        tokenId: 1,
        pricePerHour: 1000000,
        maxDuration: 12,
        expirationTime: 0,
        itemsIDs: [1, 2],
        amounts: [1, 1],
      };
      const createOrder = await market.putOnRent(orderValue, hasOr);
      const wsevwev = await market.orders(hasOr);
      expect(wsevwev[10]).to.equal(0);
      const mintToken = await token.mint(addr1.address, value2);
      const approveT = await token
        .connect(addr1)
        .approve(market.address, value2);
      const time = await ethers.provider.getBlockNumber();
      const getRent = await market.connect(addr1).rent(hasOr, 1);
      const newOrderNumbers = await market.orders(hasOr);
      const time1 = await ethers.provider.getBlock();

      await helpers.time.increase(3600);
      await helpers.mine(2000, { interval: 15 });
      const newTime = await ethers.provider.getBlock();

      const mint3 = await token.mint(addr2.address, value2);
      const approve3 = await token
        .connect(addr2)
        .approve(market.address, value2);
      const newRent = await market.connect(addr2).rent(hasOr, 2);
      const newOrderNumbers1 = await market.orders(hasOr);
    });
    it("Get rent on market", async function () {
      const {
        market,
        nftRemaster,
        deployer,
        addr1,
        addr2,
        token,
        hasOr,
        value2,
        collect,
      } = await loadFixture(deployOneYearLockFixture);
      const mintnft = await nftRemaster.mint(deployer.address, 0);
      const approvenft = await nftRemaster.approve(market.address, 1);
      const mintcol = await collect.mintAdmin(1, 1, deployer.address);
      const mintcol2 = await collect.mintAdmin(2, 1, deployer.address);
      const approv = await collect.setApprovalForAll(market.address, true);
      const orderValue = {
        status: 0,
        creator: deployer.address,
        renter: "0x0000000000000000000000000000000000000000",
        paymentToken: token.address,
        tokenTarget: nftRemaster.address,
        items: collect.address,
        data: "0x00",
        tokenId: 1,
        pricePerHour: 1000000,
        maxDuration: 12,
        expirationTime: 0,
        itemsIDs: [1, 2],
        amounts: [1, 1],
      };
      const createOrder = await market.putOnRent(orderValue, hasOr);

      const wsevwev = await market.orders(hasOr);

      expect(wsevwev[10]).to.equal(0);
      const mintToken = await token.mint(addr1.address, value2);

      const approveT = await token
        .connect(addr1)
        .approve(market.address, value2);
      const block = await ethers.provider.getBlockNumber();
      const timeInBLock = await ethers.provider.getBlock(block);

      const getRent = await market.connect(addr1).rent(hasOr, 1);
      const qwdqwd = await market.orders(hasOr);

      const mint3 = await token.mint(addr2.address, value2);
      const approve3 = await token
        .connect(addr2)
        .approve(market.address, value2);
      await expect(market.connect(addr2).rent(hasOr, 1)).to.be.revertedWith(
        "Old rent does not closed"
      );
    });
    it("Should be Error because rent is closed", async function () {
      const {
        market,
        nftRemaster,
        deployer,
        addr1,
        addr2,
        token,
        hasOr,
        value2,
        collect,
      } = await loadFixture(deployOneYearLockFixture);
      const mintnft = await nftRemaster.mint(deployer.address, 0);
      const approvenft = await nftRemaster.approve(market.address, 1);
      const mintcol = await collect.mintAdmin(1, 1, deployer.address);
      const mintcol2 = await collect.mintAdmin(2, 1, deployer.address);
      const approv = await collect.setApprovalForAll(market.address, true);
      const orderValue = {
        status: 0,
        creator: deployer.address,
        renter: "0x0000000000000000000000000000000000000000",
        paymentToken: token.address,
        tokenTarget: nftRemaster.address,
        items: collect.address,
        data: "0x00",
        tokenId: 1,
        pricePerHour: 1000000,
        maxDuration: 12,
        expirationTime: 0,
        itemsIDs: [1, 2],
        amounts: [1, 1],
      };
      const createOrder = await market.putOnRent(orderValue, hasOr);

      const wsevwev = await market.orders(hasOr);

      expect(wsevwev[10]).to.equal(0);
      const mintToken = await token.mint(addr1.address, value2);

      const approveT = await token
        .connect(addr1)
        .approve(market.address, value2);
      const cloeRent = await market.closeRentOrder(hasOr, deployer.address);
      const block = await ethers.provider.getBlock();

      const qwdqwd = await market.orders(hasOr);

      const mint3 = await token.mint(addr2.address, value2);
      const approve3 = await token
        .connect(addr2)
        .approve(market.address, value2);

      await expect(market.connect(addr2).rent(hasOr, 1)).to.be.revertedWith(
        "order closed to rent"
      );
    });
    it("Should withdraw all items from order", async function () {
      const {
        market,
        nftRemaster,
        deployer,
        addr1,
        addr2,
        token,
        hasOr,
        value2,
        collect,
      } = await loadFixture(deployOneYearLockFixture);
      const mintnft = await nftRemaster.mint(deployer.address, 0);
      const approvenft = await nftRemaster.approve(market.address, 1);
      const mintcol = await collect.mintAdmin(1, 1, deployer.address);
      const mintcol2 = await collect.mintAdmin(2, 1, deployer.address);
      const approv = await collect.setApprovalForAll(market.address, true);
      const orderValue = {
        status: 0,
        creator: deployer.address,
        renter: "0x0000000000000000000000000000000000000000",
        paymentToken: token.address,
        tokenTarget: nftRemaster.address,
        items: collect.address,
        data: "0x00",
        tokenId: 1,
        pricePerHour: 1000000,
        maxDuration: 12,
        expirationTime: 0,
        itemsIDs: [1, 2],
        amounts: [1, 1],
      };
      const createOrder = await market.putOnRent(orderValue, hasOr);
      const wsevwev = await market.orders(hasOr);
      expect(wsevwev[10]).to.equal(0);
      expect(await nftRemaster.balanceOf(deployer.address)).to.equal(0);
      const withd = await market.closeRentOrder(hasOr, deployer.address);
      expect(await nftRemaster.balanceOf(deployer.address)).to.equal(1);
    });
    it("Creation remaster rent order on market withoutr items", async function () {
      const { market, nftRemaster, deployer, token, hasOr, value2, collect } =
        await loadFixture(deployOneYearLockFixture);
      const mintnft = await nftRemaster.mint(deployer.address, 0);
      const mintcol = await collect.mintAdmin(1, 1, deployer.address);
      const mintcol2 = await collect.mintAdmin(2, 1, deployer.address);
      //const approv = await collect.setApprovalForAll(market.address, true);
      const approvenft = await nftRemaster.approve(market.address, 1);
      const orderValue = {
        status: 0,
        creator: deployer.address,
        renter: "0x0000000000000000000000000000000000000000",
        paymentToken: token.address,
        tokenTarget: nftRemaster.address,
        items: "0x0000000000000000000000000000000000000000",
        data: "0x00",
        tokenId: 1,
        pricePerHour: value2,
        maxDuration: 1,
        expirationTime: 0,
        itemsIDs: [],
        amounts: [],
      };
      const createOrder = await market.putOnRent(orderValue, hasOr);
      const time = await ethers.provider.getBlockNumber();
      const wsevwev = await market.orders(hasOr);
      //expect(wsevwev[8]).to.equal(time + 3600);
    });
  });
});
