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

  it("updateGreet with revert", async function () {
    const { deployedContract, account, otherAccount } = await loadFixture(
      deployHelloWorldFixture
    );

    const TESING_UPDATE_GREETING = "Testing update greeting";
    await expect(deployedContract.updateGreetWithRevert(TESING_UPDATE_GREETING))
      .to.not.reverted;

    await expect(
      deployedContract
        .connect(otherAccount)
        .updateGreetWithRevert(TESING_UPDATE_GREETING)
    ).to.be.revertedWith("Only the owner can call this function.");
  });

  it("updateGreet with require", async function () {
    const { deployedContract, account, otherAccount } = await loadFixture(
      deployHelloWorldFixture
    );

    const TESING_UPDATE_GREETING = "Testing update greeting";

    await expect(
      deployedContract.updateGreetWithRequire(TESING_UPDATE_GREETING)
    ).to.not.be.reverted;

    expect(await deployedContract.greet()).to.be.equal(TESING_UPDATE_GREETING);

    await expect(
      deployedContract
        .connect(otherAccount)
        .updateGreetWithRequire(TESING_UPDATE_GREETING)
    ).to.be.revertedWith("Only the owner can call this function");
  });

  describe("verify balance", async function () {
    it("zero balace and balance after txn check", async function () {
      const { deployedContract, account, otherAccount } = await loadFixture(
        deployHelloWorldFixture
      );
      // currently no transfer or fallback method implemented in the contract.
      // in beginning no ether were given to contract
      const contractAddress = deployedContract.target;
      await expect(
        await hre.ethers.provider.getBalance(contractAddress)
      ).to.be.equal(0);
    });

    it("should receive ether, emit a Transfer event, and update balances correctly", async function () {
      const { deployedContract, account } = await loadFixture(
        deployHelloWorldFixture
      );
      const contractAddress = deployedContract.target;
      const amountToSend = hre.ethers.parseEther("1");

      // sending 1 eth to contract address
      const ownerBalanceBefore = await hre.ethers.provider.getBalance(
        account.address
      );

      const txPromise = account.sendTransaction({
        to: contractAddress,
        value: amountToSend,
      });

      // Assert that the transaction emits the 'Transfer' event with the correct arguments
      await expect(txPromise)
        .to.emit(deployedContract, "Transfer")
        .withArgs(account.address, contractAddress, amountToSend);

      // Wait for the transaction to be mined to get the receipt for gas calculation
      const txResponse = await txPromise;
      const receipt = await txResponse.wait();
      expect(receipt).to.not.be.null;

      // Calculate the transaction cost
      const txCost = receipt!.gasUsed * receipt!.gasPrice;

      const contractEthBalance = await hre.ethers.provider.getBalance(
        contractAddress
      );
      expect(contractEthBalance).to.be.equal(amountToSend);
      const ownerBalanceAfter = await hre.ethers.provider.getBalance(
        account.address
      );
      expect(ownerBalanceAfter).to.be.equal(
        ownerBalanceBefore - amountToSend - txCost
      );
    });

    it("should update Greet, transfer Ether, and emit events correctly", async function () {
      const { deployedContract, account } = await loadFixture(
        deployHelloWorldFixture
      );

      const amountToSend = hre.ethers.parseEther("1");
      const TESTING_UPDATE_GREETING = "testing update greeting";
      const txnPromise = deployedContract.transferAndUpdateGreet(
        TESTING_UPDATE_GREETING,
        {
          value: amountToSend,
        }
      );
      await expect(txnPromise)
        .to.emit(deployedContract, "UpdatedGreetingMessage")
        .withArgs(account.address, TESTING_UPDATE_GREETING);
      await expect(txnPromise).to.not.emit(deployedContract, "Transfer");
      await expect(txnPromise).to.changeEtherBalances(
        [deployedContract, account],
        [amountToSend, -amountToSend]
      );
    });
  });
});
