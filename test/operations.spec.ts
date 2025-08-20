import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import hre from "hardhat";
import {expect} from "chai";

describe("Operations", function () {
  const CONTRACT_NAME = "Operations";

  async function deployOperationsFixture() {
    const [account, otherAccount] = await hre.ethers.getSigners();

    const contractFactory = await hre.ethers.getContractFactory(CONTRACT_NAME);
    const deployedContract = await contractFactory.deploy();
    await deployedContract.waitForDeployment();

    return {
      deployedContract,
      account,
      otherAccount,
    };
  }

  it("should print messages to the console during testing", async function () {
    const { deployedContract } = await loadFixture(deployOperationsFixture);

    // The constructor already adds some data. Let's call print to see it.
    console.log("\n--- Initial State ---");
    await deployedContract.print();

    // Now let's modify the state and print again.
    console.log("\n--- After Modifying State ---");
    await deployedContract.addToArray(30);
    await deployedContract.addToMapping(2, 200);
    await deployedContract.print();
  });

  it("check conditionals", async function () {
    const { deployedContract } = await loadFixture(deployOperationsFixture);
    await deployedContract.checkConditionals();
  });

  it("check loops", async function () {
    const { deployedContract } = await loadFixture(deployOperationsFixture);
    const [sum, isEqual] = await deployedContract.checkLoops(10);
    console.log(sum, isEqual);
  });

  it("check array operations", async function () {
    const { deployedContract } = await loadFixture(deployOperationsFixture);
    await deployedContract.checkArrayOperations(10);
  });

  describe("check mapping operations", async function() {
    it("check adding value", async function () {
      const {deployedContract} = await loadFixture(deployOperationsFixture);
      const key = 1;
      const value = 100;
      await deployedContract.addToMapping(key, value);
      const resValue = await deployedContract.getMappingValue(key);
      expect(resValue).is.equal(value);
    })

    it("check removing value", async function() {
      const {deployedContract} = await loadFixture(deployOperationsFixture);
      for(let i = 0; i < 10; i++) {
        const key = i;
        const value = Math.floor(Math.random() * 10000) + 1;
        await deployedContract.addToMapping(key, value);
      }
      const key = 5;
      const value = await deployedContract.getMappingValue(key);
      await deployedContract.removeKV(key);
      const newValue = await deployedContract.getMappingValue(key);
      expect(value).is.not.equal(newValue);
    })
  })
});
