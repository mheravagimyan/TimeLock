const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Lock", function () {
  async function deployLock() {
    const [owner, caller, otherAccount] = await ethers.getSigners();

    const Lock = await ethers.getContractFactory("Lock");
    const lock = await Lock.deploy(5);

    return { lock, owner, caller, otherAccount };
  }

  describe("Constructor", function() {
    it("Constructor", async function() {
      const { lock, owner, caller } = await loadFixture(deployLock);
      expect(await lock.ownerFee()).to.equal(5);
    });
  });

  describe("Constructor", function() {
    it("Constructor", async function() {
      const { lock, owner, caller } = await loadFixture(deployLock);
      expect(await lock.ownerFee()).to.equal(5);
    });
  });
});
