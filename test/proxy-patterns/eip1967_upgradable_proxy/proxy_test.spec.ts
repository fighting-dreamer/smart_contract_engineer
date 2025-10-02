import hre from "hardhat";
import {expect} from "chai"
import { SimpleProxy } from "../../../typechain-types";
import { ImplementationEIP1967One, ImplementationEIP1967Two, ImplementationEIP1967Three } from "../../../typechain-types";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
describe("Simple Proxy using EIP1967", async function () {
  async function deployContract<T>(
    contractName: string,
    args?: any[]
  ): Promise<{
    contractFactory: any;
    deployedContract: T;
    address: string;   
  }> {
    const contractFactory = await hre.ethers.getContractFactory(contractName);
    const deployedContract = (await contractFactory.deploy(...(args || []))) as T;
    await (deployedContract as any).waitForDeployment();
    const address = (deployedContract as any).target;
    return {
        contractFactory,
        deployedContract,
        address,
    }
  }

  async function deployContractFixture() {
    const [account, otherAccount] = await hre.ethers.getSigners();
    const simpleProxy = await deployContract<SimpleProxy>("SimpleProxy");
    const implementationOne = await deployContract<ImplementationEIP1967One>("ImplementationEIP1967One", []);
    const implementationTwo = await deployContract<ImplementationEIP1967Two>("ImplementationEIP1967Two", []);
    const implementatonThree = await deployContract<ImplementationEIP1967Three>("ImplementationEIP1967Three", []);

    return {
        account,
        otherAccount,
        simpleProxy,
        implementationOne,
        implementationTwo,
        implementatonThree,
    }
  }

  async function getSlotValue(contractAddress:string, slot: string):Promise<string> {
    return await hre.ethers.provider.getStorage(contractAddress, slot);
  }

  it("Checking Deployment and values of admin and implementation", async function () {
    const _ADMIN_SLOT = "0xb53127684a568b3173ae13b9f8a6016eaf15eb9e8e9f03347e2db6a3ec1e1cb0";
    const _IMPLEMENTATION_SLOT = "0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc";

    const {account, simpleProxy, implementationOne} = await loadFixture(deployContractFixture);
    // reading certain slot of the proxy.
    // check the admin slot hold address of "account" the one used in the deployment.
    const adminSlotValue = await getSlotValue(simpleProxy.address, _ADMIN_SLOT);
    console.log(adminSlotValue);
    const adminAddress = hre.ethers.getAddress(hre.ethers.dataSlice(adminSlotValue, 12));
    console.log(adminAddress);
    console.log(account.address);
    expect(adminAddress).to.equal(account.address);

    // set implementationOne as implementation of SimpleProxy
    await simpleProxy.deployedContract.setImplementation(implementationOne.address);
    // check the storage slot of implementation from simple-proxy
    const implementationSlotValue = await getSlotValue(simpleProxy.address, _IMPLEMENTATION_SLOT);
    console.log(implementationSlotValue);
    const implementationAddress = hre.ethers.getAddress(hre.ethers.dataSlice(implementationSlotValue, 12));
    console.log(implementationOne.address);
    console.log(implementationAddress);
    // check if that value matches the implementation address.
    expect(implementationAddress).to.equal(implementationOne.address);
  });

  it("checking is operation work as expected", async function () {});

  it("updating the implementation to version2", async function () {});

  it("updating the implementation to version3", async function () {});
});
