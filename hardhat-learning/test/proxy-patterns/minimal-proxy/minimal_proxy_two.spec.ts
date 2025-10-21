import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import hre from "hardhat";
import { MinimalProxy } from "../../../typechain-types";
import { CounterImplementation } from "../../../typechain-types";
import { expect } from "chai";
describe("Minimal Proxy two", async function () {
  async function contractDeployment<T>(contractName: string): Promise<{
    contractFactory: any;
    deployedContract: T;
    address: string;
  }> {
    const contractFactory = await hre.ethers.getContractFactory(contractName);

    const deployedContract = (await contractFactory.deploy()) as T;
    await (deployedContract as any).waitForDeployment();
    const address = (deployedContract as any).target;

    return {
      contractFactory,
      deployedContract,
      address,
    };
  }
  async function deployContractFixure() {
    const [account, otherAccount] = await hre.ethers.getSigners();
    const cloneFactory = await contractDeployment<MinimalProxy>("MinimalProxy");
    const implementation = await contractDeployment<CounterImplementation>(
      "CounterImplementation"
    );

    return {
      account,
      otherAccount,
      cloneFactory,
      implementation,
    };
  }

  // gives runtime code only
  async function getDeployedByteCode(address: string) {
    const deployedByteCode = await hre.ethers.provider.getCode(address);
    return deployedByteCode;
  }

  describe("match deployedByteCode", async function () {
    const { account, otherAccount, cloneFactory, implementation } =
      await loadFixture(deployContractFixure);
    console.log("Clone Factory Address : ", cloneFactory.address);
    const txnResponse = await cloneFactory.deployedContract.clone(
      implementation.address
    );
    const txnReciept = await txnResponse.wait();
    if (!txnReciept) throw new Error("No transaction receipt");
    console.log(txnReciept);

    const event = txnReciept.logs.find(
      (log) => log.topics[0] === hre.ethers.id("Cloned(address)")
    );
    if (!event) throw new Error("Cloned event not found");
    const newProxyAddress = event.args[0].toString();
    console.log("New proxy address from event:", newProxyAddress);
    const gotRuntimeDeployedByteCode = await getDeployedByteCode(
      newProxyAddress
    );
    console.log(gotRuntimeDeployedByteCode);
    const expectedDeployedByteCode =
      `0x363d3d373d3d3d363d73${implementation.address.slice(
        2
      )}5af43d82803e903d91602b57fd5bf3`.toLowerCase();
    console.log(expectedDeployedByteCode);
    expect(expectedDeployedByteCode).to.be.equal(
      gotRuntimeDeployedByteCode.toLowerCase()
    );
  });
});
