import hre from "hardhat";
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";

describe("Testing for safe math internal library usage", async function () {
  async function deployLoadFixture() {
    const [account, otherAccount] = await hre.ethers.getSigners();
    const contractFactory = await hre.ethers.getContractFactory(
      "UsingSafeMathInternal"
    );
    const deployedContract = await contractFactory.deploy();
    await deployedContract.waitForDeployment();
    const contractAddress = deployedContract.target;
    return {
      deployedContract,
      contractFactory,
      contractAddress,
      account,
      otherAccount,
    };
  }

  it("cehck addition", async function () {
    const { deployedContract } = await loadFixture(deployLoadFixture);
    const a = 100;
    const b = 200;
    const c = await deployedContract.doAddition(a, b);
    expect(c).is.equal(a + b);
  });
});
