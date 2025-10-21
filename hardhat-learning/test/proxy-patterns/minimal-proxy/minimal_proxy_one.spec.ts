import hre from "hardhat";
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";

describe("minimal proxy one", async function () {
  async function deployContractfixture() {
    const [account, otherAccount] = await hre.ethers.getSigners();

    const implementationContractFactory = await hre.ethers.getContractFactory(
      "CounterImplementation"
    );
    const counterImplementationContract =
      await implementationContractFactory.deploy();
    await counterImplementationContract.waitForDeployment();
    const counterImplementationAddresss = counterImplementationContract.target;

    const minimalProxyContractFactory = await hre.ethers.getContractFactory(
      "MinimalProxyOne"
    );
    const minimalProxyOneContract = await minimalProxyContractFactory.deploy(
      counterImplementationAddresss
    );
    await minimalProxyOneContract.waitForDeployment();
    const minimalProxyOneContractAddress = minimalProxyOneContract.target;

    return {
      account,
      otherAccount,
      counterImplementationAddresss,
      implementationContractFactory,
      counterImplementationContract,
      minimalProxyOneContractAddress,
      minimalProxyContractFactory,
      minimalProxyOneContract,
    };
  }

  describe("Testing deployment", async function () {
    it("accessing public variables via proxy", async function () {
      const {
        account,
        otherAccount,
        counterImplementationAddresss,
        implementationContractFactory,
        counterImplementationContract,
        minimalProxyOneContractAddress,
        minimalProxyContractFactory,
        minimalProxyOneContract,
      } = await loadFixture(deployContractfixture);

      const minimalProxyOneContractWithImplementationInterface =
        await hre.ethers.getContractAt(
          "CounterImplementation",
          minimalProxyOneContractAddress
        );
      const counterVal =
        await minimalProxyOneContractWithImplementationInterface.counter();
      console.log(counterVal);
      expect(counterVal).to.be.equal(0);
    });

    it("test proxy increment", async function () {
      const { minimalProxyOneContractAddress } = await loadFixture(
        deployContractfixture
      );

      const minimanProxyOneImplementationWithCounterOneInterface =
        await hre.ethers.getContractAt(
          "CounterImplementation",
          minimalProxyOneContractAddress
        );
      const counterValBefore =
        await minimanProxyOneImplementationWithCounterOneInterface.counter();
      const txn =
        await minimanProxyOneImplementationWithCounterOneInterface.inc();
      const counterValAfter =
        await minimanProxyOneImplementationWithCounterOneInterface.counter();
      expect(counterValAfter - counterValBefore).to.be.equal(1);
    });
  });
});
