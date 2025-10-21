import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import hre from "hardhat";
import {expect} from "chai";


describe("FirstApp", function() {
    const CONTRACT_NAME="Counter";
    const deploymentArgs: never[] = [];

    async function deployContractFixture() {
        const [account, otherAccount] = await hre.ethers.getSigners();
        
        const contractFactory = await hre.ethers.getContractFactory(CONTRACT_NAME);
        const deployedContract = await contractFactory.deploy(...deploymentArgs);
        await deployedContract.waitForDeployment();
        const contractAddress = deployedContract.target;
        console.log(contractAddress);

        return {
            deployedContract,
            contractFactory,
            contractAddress,
            account,
            otherAccount,
        }
    }

    describe("checking deployed", async function() {
        it("check bytecode and confirm deployment and check balance", async function() {
            const { contractAddress } = await loadFixture(deployContractFixture);

            // The bytecode from the factory (`contractFactory.bytecode`) is the "creation bytecode".
            // It includes the constructor logic and the code that returns the runtime bytecode.
            // The code stored on the network is the "runtime bytecode", which is what's left after the constructor runs.
            // To properly compare, we need the runtime bytecode from the compiled artifact.
            const artifact = await hre.artifacts.readArtifact(CONTRACT_NAME);
            const deployedBytecodeFromArtifact = artifact.deployedBytecode;
            const byteCodeFromNetwork = await hre.ethers.provider.getCode(contractAddress);

            expect(deployedBytecodeFromArtifact).is.not.equal("0x");
            expect(byteCodeFromNetwork).is.not.equal("0x");
            expect(byteCodeFromNetwork).is.equal(deployedBytecodeFromArtifact);
        })

        it("check increment", async function() {
            const {deployedContract} = await loadFixture(deployContractFixture);
            const currentCount = await deployedContract.get();
            console.log(currentCount);
            const txn = await deployedContract.inc();
            console.log(txn);
            const newCount = await deployedContract.get();
            expect(newCount).is.equal(currentCount + 1n);
        })

        it("check decrement", async function () {
            const {deployedContract} = await loadFixture(deployContractFixture);
            const txn = await deployedContract.inc(); // its antransaction, not a call.
            console.log("TXN \n", txn);
            const txnReceipt = await txn.wait();
            console.log("Receipt \n", txnReceipt);

            const count = await deployedContract.get();
            await deployedContract.dec();
            const newCount = await deployedContract.get();
            expect(newCount).is.equal(count - 1n);
        })

        it("check decrement should throw error", async function() {
            const {deployedContract} = await loadFixture(deployContractFixture);

            const currentCount = await deployedContract.get();
            console.log("Current Count : ", currentCount)
            const txnPromise = deployedContract.dec();
            expect(txnPromise).to.be.revertedWithPanic(0x11);
        })
    })
})
