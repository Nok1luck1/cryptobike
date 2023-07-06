import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { BigNumber } from "ethers";
import { expect } from "chai";

const { upgrades, ethers } = require("hardhat");
import Player from "../artifacts/contracts/Account721.sol/Account721.json";
describe("Account Test", function () {
  async function deployOneYearLockFixture() {
    const [deployer, addr1, addr2] = await ethers.getSigners();

    const PVP = await ethers.getContractFactory("PvpContr");
    const init = [deployer.address];
    const pvp = await upgrades.deployProxy(PVP, init, {
      initializer: "initialize",
      kind: "uups",
    });
    await pvp.deployed();

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

    return {
      deployer,
      addr1,
      addr2,
      token,
      nft,
      pvp,
      collect,
      value2,
    };
  }
  it("Enter nfts in pvp", async function () {
    const { deployer, token, value2, nft, collect, pvp } = await loadFixture(
      deployOneYearLockFixture
    );
    const approveByke = await nft.mint(deployer.address, 2);
    const aprrver = await nft.approve(pvp.address, 2);
    const aprrver1 = await nft.approve(pvp.address, 1);
    const mint115 = await collect.mint(deployer.address, 1, 100);
    const mint123fd = await collect.mint(deployer.address, 2, 100);
    const apprve = await collect.setApprovalForAll(pvp.address, true);
    const depo = await pvp.depositItems(true, {
      items: collect.address,
      erc721: [nft.address, nft.address],
      id721: [1, 2],
      itemsId: [1, 2],
      itemsAmount: [1, 1],
    });
    //
    const result = await pvp.userPositedNFTs(deployer.address);
    const egfwe = await pvp.check(deployer.address);
    expect(egfwe.erc721).to.deep.equal([nft.address, nft.address]);
  });
  it("Enter nfts in pvp from 2 users and runs race", async function () {
    const { deployer, token, value2, nft, collect, pvp, addr1 } =
      await loadFixture(deployOneYearLockFixture);
    const approveByke = await nft.mint(deployer.address, 2);
    const aprrver = await nft.approve(pvp.address, 2);
    const aprrver1 = await nft.approve(pvp.address, 1);
    const mint115 = await collect.mint(deployer.address, 1, 100);
    const mint123fd = await collect.mint(deployer.address, 2, 100);
    const apprve = await collect.setApprovalForAll(pvp.address, true);
    const depo = await pvp.depositItems(true, {
      items: collect.address,
      erc721: [nft.address, nft.address],
      id721: [1, 2],
      itemsId: [1, 2],
      itemsAmount: [1, 1],
    });
    //
    const result = await pvp.userPositedNFTs(deployer.address);
    const egfwe = await pvp.check(deployer.address);

    expect(egfwe.erc721).to.deep.equal([nft.address, nft.address]);
    const approveByke1 = await nft.mint(addr1.address, 3);
    const approveByke14 = await nft.mint(addr1.address, 4);
    const aprrver12 = await nft.connect(addr1).approve(pvp.address, 3);
    const aprrver11 = await nft.connect(addr1).approve(pvp.address, 4);
    const mint1151 = await collect.mint(addr1.address, 1, 100);
    const mint123fd1 = await collect.mint(addr1.address, 2, 100);
    const apprve1 = await collect
      .connect(addr1)
      .setApprovalForAll(pvp.address, true);
    const depo1 = await pvp.connect(addr1).depositItems(true, {
      items: collect.address,
      erc721: [nft.address, nft.address],
      id721: [3, 4],
      itemsId: [1, 2],
      itemsAmount: [1, 1],
    });
    const setwin = await pvp.setNewBalance(
      {
        items: collect.address,
        erc721: [nft.address, nft.address, nft.address],
        id721: [1, 2, 3],
        itemsId: [1, 2],
        itemsAmount: [2, 2],
      },
      deployer.address,
      {
        items: collect.address,
        erc721: [nft.address],
        id721: [3],
        itemsId: [],
        itemsAmount: [],
      },
      addr1.address
    );
    const reulst = await pvp.check(deployer.address);

    expect(reulst.id721).to.deep.equal([
      BigNumber.from(1),
      BigNumber.from(2),
      BigNumber.from(3),
    ]);
  });
  it("Enter nfts in pvp from 2 users and runs race, and withdraw", async function () {
    const { deployer, token, value2, nft, collect, pvp, addr1 } =
      await loadFixture(deployOneYearLockFixture);
    const approveByke = await nft.mint(deployer.address, 2);
    const aprrver = await nft.approve(pvp.address, 2);
    const aprrver1 = await nft.approve(pvp.address, 1);
    const mint115 = await collect.mint(deployer.address, 1, 100);
    const mint123fd = await collect.mint(deployer.address, 2, 100);
    const apprve = await collect.setApprovalForAll(pvp.address, true);
    const depo = await pvp.depositItems(true, {
      items: collect.address,
      erc721: [nft.address, nft.address],
      id721: [1, 2],
      itemsId: [1, 2],
      itemsAmount: [1, 1],
    });
    //
    const result = await pvp.userPositedNFTs(deployer.address);
    const egfwe = await pvp.check(deployer.address);

    expect(egfwe.erc721).to.deep.equal([nft.address, nft.address]);
    const approveByke1 = await nft.mint(addr1.address, 3);
    const approveByke14 = await nft.mint(addr1.address, 4);
    const aprrver12 = await nft.connect(addr1).approve(pvp.address, 3);
    const aprrver11 = await nft.connect(addr1).approve(pvp.address, 4);
    const mint1151 = await collect.mint(addr1.address, 1, 100);
    const mint123fd1 = await collect.mint(addr1.address, 2, 100);
    const apprve1 = await collect
      .connect(addr1)
      .setApprovalForAll(pvp.address, true);
    const depo1 = await pvp.connect(addr1).depositItems(true, {
      items: collect.address,
      erc721: [nft.address, nft.address],
      id721: [3, 4],
      itemsId: [1, 2],
      itemsAmount: [1, 1],
    });
    const setwin = await pvp.setNewBalance(
      {
        items: collect.address,
        erc721: [nft.address, nft.address, nft.address],
        id721: [1, 2, 3],
        itemsId: [1, 2],
        itemsAmount: [2, 2],
      },
      deployer.address,
      {
        items: collect.address,
        erc721: [nft.address],
        id721: [4],
        itemsId: [],
        itemsAmount: [],
      },
      addr1.address
    );
    const reulst = await pvp.check(deployer.address);

    expect(reulst.id721).to.deep.equal([
      BigNumber.from(1),
      BigNumber.from(2),
      BigNumber.from(3),
    ]);
    const withdraW = await pvp.withdrawBalance(
      {
        items: collect.address,
        erc721: [nft.address, nft.address, nft.address],
        id721: [1, 2, 3],
        itemsId: [1, 2],
        itemsAmount: [2, 2],
      },
      {
        items: collect.address,
        erc721: [],
        id721: [],
        itemsId: [],
        itemsAmount: [],
      },
      deployer.address
    );
    const ewcec = await pvp.check(deployer.address);
    expect(ewcec.id721).to.deep.equal([]);
  });
});
