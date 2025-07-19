import {
  loadFixture,
  time,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import hre from "hardhat";
import { expect } from "chai";

describe("testing user defined values", async function () {
  async function deployLoadFixture() {
    const [account, otherAccount] = await hre.ethers.getSigners();
    const contractFactory = await hre.ethers.getContractFactory(
      "UserDefinedValueTypesExamples"
    );
    const deployedContract = await contractFactory.deploy();
    await deployedContract.waitForDeployment();
    const contractAddress = deployedContract.target;
    return {
      deployedContract,
      contractFactory,
      contractAddress,
      account,
      otherAccount,
    };
  }

  describe("return clock", async function () {
    it("should return a packed value that can be unpacked in TypeScript", async function () {
      const { deployedContract } = await loadFixture(deployLoadFixture);

      // `example_no_uvdt` is a view function, so it uses the timestamp of the latest block.
      const latestBlockTimestamp = await time.latest();

      const clockValue = await deployedContract.example_no_uvdt();

      console.log("Returned Clock value (as BigInt):", clockValue);
      console.log("Type of returned value:", typeof clockValue);

      // In Solidity, the Clock type is a uint128. In ethers.js, this is represented as a BigInt.
      // To use it effectively, you need to unpack the data just like the `LibClock` library does in Solidity.

      // The `LibClock.wrap` function packs the data like this:
      // clock = (duration << 64) | timestamp
      // So, the most significant 64 bits are the duration, and the least significant 64 bits are the timestamp.

      // We can unpack it in TypeScript using bitwise operations on BigInts.
      const duration = clockValue >> 64n;
      const timestamp = clockValue & 0xffffffffffffffffn; // Mask for the lower 64 bits

      console.log("Unpacked duration:", duration);
      console.log("Unpacked timestamp:", timestamp);

      // The contract function `example_no_uvdt` intentionally swaps the arguments:
      // clock = LibClockBasic.wrap(t, d);
      // where t = block.timestamp and d = 1.
      // This means the 'duration' part of the clock will hold the timestamp, and the 'timestamp' part will hold 1.
      expect(duration).to.equal(BigInt(latestBlockTimestamp));
      expect(timestamp).to.equal(1n);
    });
  });
});
