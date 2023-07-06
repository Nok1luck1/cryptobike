import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { time } from "@nomicfoundation/hardhat-network-helpers";
import { BigNumber } from "ethers";
import { expect } from "chai";
const helpers = require("@nomicfoundation/hardhat-network-helpers");
const { upgrades, ethers } = require("hardhat");

describe("Vesting Test", function () {
  async function deployOneYearLockFixture() {
    const [deployer, addr1, addr2] = await ethers.getSigners();
    const Token = await ethers.getContractFactory("TEST");
    const token = await Token.deploy();
    await token.deployed();

    const contr = await ethers.getContractFactory("Vesting");
    const init = [deployer.address, token.address];
    const Vesting = await upgrades.deployProxy(contr, init, {
      initializer: "initialize",
      kind: "uups",
    });
    await Vesting.deployed();

    const value = BigNumber.from("1000000000000000");
    const value2 = BigNumber.from("1000000000000000000");
    const hasOr =
      "0x0000000000000000000000000000000000000000000000000000000000000001";

    return {
      deployer,
      addr1,
      addr2,
      token,
      value2,
      Vesting,
      hasOr,
    };
  }

  it("Creation vesting for user", async function () {
    const { deployer, token, value2, Vesting, hasOr, addr2 } =
      await loadFixture(deployOneYearLockFixture);
    const mint1 = await token.mint(
      Vesting.address,
      BigNumber.from("1000000000000000000000")
    );

    const time: number = await Vesting.time();
    console.log(time, "0 time");
    const maxValueToGet = BigNumber.from(1200000);
    const VestingSCh = {
      beneficiary: addr2.address,
      claimedPeriods: 1,
      totalPeriods: 12,
      periodDuration: 3600,
      cliff: 1400,
      startTime: time,
      amountTotal: maxValueToGet,
      released: 0,
    };
    const create = await Vesting.createVestingSchedule(hasOr, VestingSCh);
    const baalnce12 = await token.balanceOf(addr2.address);
    await helpers.time.increase(16123);
    await helpers.mine(16745, { interval: 1 });
    var time1: number = await Vesting.time();
    const newTime = await ethers.provider.getBlock();
    const tryTr = await Vesting.connect(addr2).claim(hasOr);
    console.log(tryTr, "claim ");
    const check = await Vesting.vestingSchedules(hasOr);
    const baalnce1 = await token.balanceOf(addr2.address);
    const balanceAFT = await token.balanceOf(addr2.address);
    await helpers.time.increase(8000);
    await helpers.mine(8000, { interval: 1 });
    const swedvsdv = await Vesting.vestingSchedules(hasOr);
    const tryTr1 = await Vesting.connect(addr2).claim(hasOr);
    const check1 = await Vesting.vestingSchedules(hasOr);
    const baalnce13 = await token.balanceOf(addr2.address);
    expect(baalnce13).to.equal(maxValueToGet);
  });
});
