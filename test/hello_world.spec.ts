import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre from "hardhat";

describe("HelloWorld", function () {
  const TESTING_GREETING = "Testing Greeting";

  async function deployHelloWorldFixture() {
    const [account, otherAccount] = await hre.ethers.getSigners();

    const contractFactory = await hre.ethers.getContractFactory("HelloWorld");
    const deployedContract = await contractFactory.deploy(TESTING_GREETING);
    await deployedContract.waitForDeployment(); // Ensures contract is mined before snapshot
    const address = deployedContract.target;
    return {
      deployedContract,
      contractFactory,
      address,
      account,
      otherAccount,
    };
  }

  describe("checking deployed", async function () {
    it("check bytecode and confirm deployment", async function () {
      const { contractFactory, address } = await loadFixture(
        deployHelloWorldFixture
      );
      console.log(address);
      const bytecode = contractFactory.bytecode;
      console.log("ByteCode Length : ", bytecode.length);
      expect(bytecode).is.not.equal("0x");

      const deployedByteCode = await hre.ethers.provider.getCode(address);
      console.log("Deployed ByteCode Length : ", deployedByteCode.length);
      expect(deployedByteCode).is.not.equal("0x");
    });
  });
  it("greet initiated with constant", async function () {
    const { deployedContract } = await loadFixture(deployHelloWorldFixture);
    const greet = await deployedContract.greet();
    expect(greet).is.not.equal("Hello World");
    expect(greet).is.equal(TESTING_GREETING);
  });

  it("updating greeting", async function () {
    const { deployedContract } = await loadFixture(deployHelloWorldFixture);
    const TESING_UPDATE_GREETING = "Testing Update Greeting";
    await deployedContract.updateGreet(TESING_UPDATE_GREETING);
    const updatedGreet = await deployedContract.greet();
    expect(updatedGreet).is.equal(TESING_UPDATE_GREETING);
  });

  it("emits event", async function () {
    const { deployedContract, account, otherAccount } = await loadFixture(
      deployHelloWorldFixture
    );
    const TESING_UPDATE_GREETING = "Testing Update Greeting";
    const testEventName = "UpdatedGreetingMessage";

    await expect(deployedContract.updateGreet(TESING_UPDATE_GREETING))
      .to.emit(deployedContract, testEventName)
      .withArgs(account.address, TESING_UPDATE_GREETING);

    await expect(
      deployedContract.connect(otherAccount).updateGreet(TESTING_GREETING)
    )
      .to.emit(deployedContract, testEventName)
      .withArgs(otherAccount, TESTING_GREETING);
  });

  it("updateGreet with revert", async function() {
    const {deployedContract, account, otherAccount} = await loadFixture(deployHelloWorldFixture);

    const TESING_UPDATE_GREETING = "Testing update greeting";
    await expect(deployedContract.updateGreetWithRevert(TESING_UPDATE_GREETING)).to.not.reverted;

    await expect(deployedContract.connect(otherAccount).updateGreetWithRevert(TESING_UPDATE_GREETING)).to.be.revertedWith("Only the owner can call this function.")
  })
});
