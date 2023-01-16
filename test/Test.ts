import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { BigNumber } from "ethers";
import { expect } from "chai";

const { upgrades, ethers } = require("hardhat");
import Player from "../artifacts/contracts/AccountPlayer.sol/AccountPlayer.json";
//import Token from "../artifacts/contracts/test/ERC20.sol/TEST.json";
describe("Factory Market", function () {
  async function deployOneYearLockFixture() {
    const [deployer, addr1, addr2] = await ethers.getSigners();
    console.log(deployer.address, "deployed address");
    const FactoryMarketContr = await ethers.getContractFactory("FactoryMarket");
    const initValue = [
      deployer.address, //must be owner
    ];
    const market = await upgrades.deployProxy(FactoryMarketContr, initValue, {
      initializer: "initialize",
      kind: "uups",
    });
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
    return { market, deployer, addr1, addr2, token, nft, collect };
  }

  describe("Creation Account", function () {
    it("Should created Account and check Ownership", async function () {
      const { market, deployer, addr1, addr2 } = await loadFixture(
        deployOneYearLockFixture
      );

      const createAccountAddress = await market
        .connect(addr1)
        .generateAccount(123);
      const addressGenerated = await market.accountAddress(addr1.address);
      console.log(`${addressGenerated},Account created`);
      const generatedAcc = await ethers.getContractAt(
        Player.abi,
        addressGenerated
      );
      const vavl = await generatedAcc.currentowner();
      console.log(vavl, "123123123");
      expect(vavl.toLowerCase()).to.equal(addr1.address.toLowerCase());
    });

    it("Should transfer token from marketplace", async function () {
      const { market, deployer, token } = await loadFixture(
        deployOneYearLockFixture
      );

      const approve = await token
        .connect(deployer)
        .approve(market.address, 1000000000000);
      await approve.wait();
      console.log(await token.balanceOf(deployer.address));
      console.log(await token.allowance(deployer.address, market.address));
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
    it("Should create order with Account", async function () {
      const { market, deployer, token, collect, addr1 } = await loadFixture(
        deployOneYearLockFixture
      );
      const createdAccount = await market.connect(addr1).generateAccount(123);
      const generated = await market.accountAddress(addr1.address);
      const hasOr =
        "0x0000000000000000000000000000000000000000000000000000000000000003";
      expect(
        await market
          .connect(addr1)
          .createOrder(
            2,
            generated,
            token.address,
            hasOr,
            "0x00",
            BigNumber.from("1000000000000000"),
            0,
            0
          )
      )
        .to.emit(market, "CreatedOrder")
        .withArgs(collect.address, deployer.address, hasOr, 2);
    });
    it("Should create account sell if and buy from another account", async function () {
      const { market, deployer, token, collect, addr1, addr2 } =
        await loadFixture(deployOneYearLockFixture);
      const value = BigNumber.from("1000000000000000");
      const value2 = BigNumber.from("1000000000000000000");
      const createdAccount = await market.connect(addr1).generateAccount(123);
      const generated = await market.accountAddress(addr1.address);
      const hasO1r =
        "0x0000000000000000000000000000000000000000000000000000000000000013";
      const createAccount = await market
        .connect(addr1)
        .createOrder(2, generated, token.address, hasO1r, "0x00", value, 0, 0);
      const mintAcc2 = await token.connect(addr2).mint(addr2.address, value2);
      const approveAcc2 = await token
        .connect(addr2)
        .approve(market.address, value2);
      const checkAllowance = await token.allowance(
        addr2.address,
        market.address
      );
      const balance = await token.balanceOf(addr2.address);
      const Account = await ethers.getContractAt(Player.abi, generated);
      const owner1 = await Account.currentowner();
      expect(await market.connect(addr2).buyFromOrder(hasO1r, 1, addr2.address))
        .to.emit(market, "BuyInOrder")
        .withArgs(generated, addr2.address, hasO1r, 2);
      expect(await Account.currentowner()).to.equal(addr2.address);
    });
  });
});
