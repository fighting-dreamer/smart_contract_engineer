import { loadFixture } from '@nomicfoundation/hardhat-toolbox/network-helpers';
import hre from 'hardhat';
import { expect } from "chai";


describe("SimpleStorage", function () {

    async function deploySimpleStorageFixture() {
        const [account, otherAccount] = await hre.ethers.getSigners();

        const simpleStorageContract = await hre.ethers.getContractFactory("SimpleStorage");
        const simpleStorageDeployed = await simpleStorageContract.deploy();
        console.log(await simpleStorageDeployed.getAddress());
        console.log(simpleStorageDeployed);
        console.log("---------------------------------------------\n")
        return {simpleStorageDeployed, account, otherAccount}
    }

    describe("Deployment", function () {
        it("it should store and show messages", async function() {
            const {simpleStorageDeployed, account, otherAccount} = await loadFixture(deploySimpleStorageFixture);
            const message = "test message";
            const txnRes = await simpleStorageDeployed.store(message);
            console.log(txnRes);
            console.log("-------------------------------------------\n")
            const index = 0;
            const res = await simpleStorageDeployed.getMessage(index);
            console.log(res);
            expect(message === res);
        })
    })
})