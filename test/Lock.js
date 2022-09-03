const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("TimeLock", function () {
  async function deployTimeLock() {
    const [owner, caller, otherAccount] = await ethers.getSigners();

    const TimeLock = await ethers.getContractFactory("TimeLock");
    const lock = await TimeLock.deploy(5);

    return { lock, owner, caller, otherAccount };
  }

  describe("Initialization", function() {
    it("Should initialize with correct args: ", async function() {
      const { lock, owner, caller } = await loadFixture(deployTimeLock);
      expect(await lock.ownerFee()).to.equal(5);
    });
  });

  describe("Lock requires", function() {
    it("Should revert with 'Not enough funds!' ", async function() {
      const { lock, owner, caller } = await loadFixture(deployTimeLock);
      const tokenAmount = [100];
       const tokenAddress = [
        "0x326C977E6efc84E512bB9C30f76E30c160eD06FB"
        // "0x01BE23585060835E02B77ef475b0Cc51aA1e0709"
        // "0x0000000000000000000000000000000000000000"
      ];
      const lockTime = 10;


      await expect(lock.lock(tokenAmount, tokenAddress, lockTime))
        .to.be.revertedWith("Not enough funds!");
    });

    it("Should revert with 'Have no approve!' ", async function() {
      const { lock, owner, caller } = await loadFixture(deployTimeLock);
      const tokenAmount = [100];
       const tokenAddress = [
        "0x326C977E6efc84E512bB9C30f76E30c160eD06FB"
        // "0x01BE23585060835E02B77ef475b0Cc51aA1e0709"
        // "0x0000000000000000000000000000000000000000"
      ];
      const lockTime = 10;


      await expect(lock.lock(tokenAmount, tokenAddress, lockTime))
        .to.be.revertedWith("Have no approve!");
    });
  });

  // describe("Lock", function() {
  //   it("Should ", async function() {
  //     const { lock, owner, caller } = await loadFixture(deployTimeLock);
  //     const tokenAmount = [100, 200];
  //     const tokenAddress = [
  //       0x514910771AF9Ca656af840dff83E8264EcF986CA, // Chainlink Token
  //       0x0000000000000000000000000000000000000000
  //     ];
  //     const lockTime = 10;

  //     await lock.lock(tokenAmount, tokenAddress, lockTime, {value: 100});
    
  //     const user = lock.locks(owner.address);
      
  //     expect(user.amout);
  //     expect();
  //     expect();
  //     expect();
  //   });
  // });
});
