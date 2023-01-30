const { expect } = require('chai');
const { ethers } = require("hardhat")
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("Cryptobox tests", async function() {

    async function deployFixture() {
        let token;
        let exchange;
        const signers = await ethers.getSigners();
        let owner = signers[0];
        let user = signers[1];
        let user2 = signers[2];

        const Token = await ethers.getContractFactory("MTCBToken");
        token = await Token.deploy();
        await token.deployed();

        const Exchange = await ethers.getContractFactory("TokenExchange");
        exchange = await Exchange.deploy(token.address, user2.address, 3330);
        await exchange.deployed();

        await token.connect(owner).transfer(user.address, ethers.utils.parseUnits("1000000", 18))

        return { token, exchange, owner, user, user2 };
    }

    it("Should deposit token", async function() {
        const { token, exchange, owner, user, user2 } = await loadFixture(deployFixture);
        let amount = ethers.utils.parseUnits("10000", 18)
        await token.connect(user).approve(exchange.address, amount)
        await exchange.connect(user).depositToken(amount)
        expect(await token.connect(user).balanceOf(user2.address)).to.equal(amount);
    })

    it("Should revert deposit cause min limit", async function() {
        const { token, exchange, owner, user } = await loadFixture(deployFixture);
        let amount = ethers.utils.parseUnits("3329", 18)
        await token.connect(user).approve(exchange.address, amount)
        await expect(exchange.connect(user).depositToken(amount)).to.be.revertedWith('You have sent less tokens than needed for the exchange')
    })

    it("Should change limit and test", async function() {
        const { token, exchange, owner, user } = await loadFixture(deployFixture);
        await exchange.connect(owner).setNewLimit(10000)
        let amount = ethers.utils.parseUnits("9000", 18)
        await token.connect(user).approve(exchange.address, amount)
        await expect(exchange.connect(user).depositToken(amount)).to.be.revertedWith('You have sent less tokens than needed for the exchange')
    })

    it("Should change limit and test 2", async function() {
        const { token, exchange, owner, user, user2 } = await loadFixture(deployFixture);
        await exchange.connect(owner).setNewLimit(10000)
        let amount = ethers.utils.parseUnits("10000", 18)
        await token.connect(user).approve(exchange.address, amount)
        await exchange.connect(user).depositToken(amount)
        expect(await token.connect(user).balanceOf(user2.address)).to.equal(amount);
    })

})