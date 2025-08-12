import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre from "hardhat";

describe("HelloWorld", function () {
  async function deployHelloWorldFixture() {
    const [account, otherAccount] = await hre.ethers.getSigners();

    const contractFactory = await hre.ethers.getContractFactory("HelloWorld");
    const deployedContract = await contractFactory.deploy();
    await deployedContract.waitForDeployment();
    const address = await deployedContract.getAddress();
    console.log(address)
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
      console.log(address)
      const bytecode = contractFactory.bytecode;
      console.log("ByteCode : ", bytecode);
      expect(bytecode).is.not.equal("0x");

      const deployedByteCode = await hre.ethers.provider.getCode(address);
      console.log("Deployed ByteCode : ", deployedByteCode);
      expect(deployedByteCode).is.not.equal("0x");
    });
  });
  it("greet initiated with constant", async function() {
    const {deployedContract} = await loadFixture(deployHelloWorldFixture);
    const greet = await deployedContract.greet();
    console.log(greet);
    expect(greet).to.equal("Hello World");
  })
});
