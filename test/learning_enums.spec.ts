import hre from "hardhat";
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";

// Using an object for enums in tests improves readability
const OrderState = {
  PLACED: 0,
  CONFIRMED: 1,
  PREPARED: 2,
  ASSIGNED: 3,
  ON_THE_WAY: 4,
  DELIVERED: 5,
  CANCELLED: 6,
  TERMINATED: 7,
  REFUNDED: 8,
};

describe("Test Learning Enums", async function () {
  async function deployContractFixture() {
    const [account, otherAccount] = await hre.ethers.getSigners();
    const contractfactory_LearnEnums = await hre.ethers.getContractFactory(
      "LearnEnums"
    );
    const deployedContract_LearnEnums =
      await contractfactory_LearnEnums.deploy();
    const contractFactory_TestLearningEnums =
      await hre.ethers.getContractFactory("TestLearningEnums");
    const deployedContract_TestLearningEnums =
      await contractFactory_TestLearningEnums.deploy();

    await deployedContract_LearnEnums.waitForDeployment();
    await deployedContract_TestLearningEnums.waitForDeployment();
    const learnEnumsContractAddress = deployedContract_LearnEnums.target;
    const testLearningEnumsContractAddress =
      deployedContract_TestLearningEnums.target;

    console.log("LearnEnums : ", learnEnumsContractAddress);
    console.log("TestLearningEnums : ", testLearningEnumsContractAddress);

    return {
      account,
      otherAccount,

      deployedContract_LearnEnums,
      contractfactory_LearnEnums,

      deployedContract_TestLearningEnums,
      contractFactory_TestLearningEnums,

      learnEnumsContractAddress,
      testLearningEnumsContractAddress,
    };
  }

  describe("Testing pure functions: computeArrayHash", async function () {
    it("should compute the correct hash for a sorted array", async function () {
      const { deployedContract_TestLearningEnums } = await loadFixture(
        deployContractFixture
      );
      const sortedArr = [OrderState.PLACED, OrderState.CONFIRMED]; // [0, 1]
      console.log(sortedArr);
      // Replicate Solidity's abi.encodePacked in ethers.
      // Enums are treated as uint8.
      const packedData = hre.ethers.solidityPacked(
        ["uint8", "uint8"],
        sortedArr
      );

      const expectedHash = hre.ethers.keccak256(packedData);
      const actualHash =
        await deployedContract_TestLearningEnums.testComputeArrayHash(
          sortedArr
        );

      expect(actualHash).to.equal(expectedHash);
    });

    it("should compute an correct hash for an unsorted array", async function () {
      const { deployedContract_TestLearningEnums } = await loadFixture(
        deployContractFixture
      );
      const unsortedArr = [OrderState.CONFIRMED, OrderState.PLACED]; // [1, 0]
      const sortedArr = [OrderState.PLACED, OrderState.CONFIRMED]; // [0, 1]

      const packedData = hre.ethers.solidityPacked(
        ["uint8", "uint8"],
        sortedArr
      );
      const expectedHash = hre.ethers.keccak256(packedData);

      const actualHash =
        await deployedContract_TestLearningEnums.testComputeArrayHash(
          unsortedArr
        );

      expect(actualHash).to.equal(expectedHash);
    });
  });
  describe("Testing pure functions : containsOrderState", async function () {
    it("when state exist in the array", async function () {
      const { deployedContract_TestLearningEnums } = await loadFixture(
        deployContractFixture
      );
      const orderStateArr = [OrderState.ON_THE_WAY, OrderState.DELIVERED];
      const testState = OrderState.DELIVERED;
      let [index, ok] =
        await deployedContract_TestLearningEnums.testContainsOrderState(
          orderStateArr,
          testState
        );
      expect(ok).to.equal(true);
      expect(index).to.equal(1);
    });

    it("when state does not exist in the array", async function () {
      const { deployedContract_TestLearningEnums } = await loadFixture(
        deployContractFixture
      );
      const orderStateArr = [OrderState.ON_THE_WAY, OrderState.DELIVERED];
      const testState = OrderState.ASSIGNED;
      let [index, ok] =
        await deployedContract_TestLearningEnums.testContainsOrderState(
          orderStateArr,
          testState
        );
      expect(ok).to.equal(false);
      expect(index).to.equal(0);
    });
  });

  describe("Testing order state removal", async function () {
    it("check if required state is removed", async function () {
      const { deployedContract_TestLearningEnums } = await loadFixture(
        deployContractFixture
      );

      const orderStates = [
        OrderState.PLACED,
        OrderState.DELIVERED,
        OrderState.PREPARED,
      ];
      console.log("Order States : ", orderStates);
      const toBeRemovedState = OrderState.DELIVERED;
      const indexOfToBeRemovedState = orderStates.findIndex(
        (state) => state === toBeRemovedState
      );
      console.log("TO BE REMOVED INDEX : ", indexOfToBeRemovedState);

      const expectedOrderStates = orderStates.filter(
        (state) => state !== toBeRemovedState
      );
      console.log("Expected Order State : ", expectedOrderStates);
      const txn = await deployedContract_TestLearningEnums.testRemoveOrderState(
        orderStates,
        indexOfToBeRemovedState
      );
      const txnReciept = await txn.wait();
      const gotOrderStates =
        await deployedContract_TestLearningEnums.debugGetOrderStates();
      console.log("Got Order States : ", gotOrderStates);
      expect(gotOrderStates).to.be.deep.equal(expectedOrderStates);
    });
  });
});
