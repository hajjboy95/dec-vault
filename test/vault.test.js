/* eslint-env mocha */

const { expect } = require('chai')

describe("Vault", () => {
  
    let vault;
    let weth;

    before(async () => {
      [deployer, user] = await ethers.getSigners()
      const WEth = await ethers.getContractFactory('WETH9')
      weth = await WEth.deploy()
      await weth.deployed()


      const Vault = await ethers.getContractFactory('Vault')
      vault = await Vault.deploy(weth.address)
      await vault.deployed()
    });

    it("should deposit ETH correctly", async () => {
        const depositAmount = ethers.utils.parseUnits('1', 'ether');

        await vault.connect(user).depositEth({ value: depositAmount });

        const balance = await vault.ethBalances(user.address);
        expect(balance.toString()).equal(depositAmount)
    });

    it("should wrap ETH to WETH correctly", async () => {
        const wrapAmount = ethers.utils.parseUnits('1', 'ether');

        await vault.connect(user).wrapEthToWEth(wrapAmount);

        const wethBalance = await vault.tokenBalances(weth.address, user.address);

        expect(wethBalance.toString()).equal(wrapAmount)
    });

    it("should unwrap WETH to ETH successfully", async () => {
    });

    it("should withdraw ETH successfully", async () => {
    });

});