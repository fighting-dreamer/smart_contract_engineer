import hre from "hardhat";
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";

describe("Testing for safe math external library usage", async function () {
  // This fixture now correctly deploys the contract by linking the required library.
  async function deployLoadFixture() {
    const [account, otherAccount] = await hre.ethers.getSigners();

    // 1. Deploy the library first
    const libraryFactory = await hre.ethers.getContractFactory(
      "MyExternalSafeMath"
    );
    const deployedLibrary = await libraryFactory.deploy();
    await deployedLibrary.waitForDeployment();
    const libraryAddress = await deployedLibrary.getAddress();

    // 2. Get the contract factory, providing the deployed library's address
    const contractFactory = await hre.ethers.getContractFactory(
      "UsingSafeMathExternal",
      {
        libraries: {
          // The key for the libraries object must be the fully qualified name.
          "contracts/library/my_external_safe_math.sol:MyExternalSafeMath":
            libraryAddress,
        },
      }
    );

    // 3. Deploy the main contract
    const deployedContract = await contractFactory.deploy();
    await deployedContract.waitForDeployment();
    return {
      deployedContract,
      account,
      otherAccount,
    };
  }

  it("cehck addition", async function () {
    const { deployedContract } = await loadFixture(deployLoadFixture);
    const a = 100;
    const b = 200;
    const c = await deployedContract.doAddition(a, b);
    expect(c).to.equal(a + b);
  });

  it("check identity", async function () {
    const { deployedContract } = await loadFixture(deployLoadFixture);
    expect(await deployedContract.doIdentity(123)).to.equal(123);
  });

  describe("Testing external library function usage", function () {
    it("should fail to deploy without linking", async function () {
      // const contractFactory = await hre.ethers.getContractFactory(
      //   "UsingSafeMathExternal"
      // );
      let thrownError = false;
      try {
        await hre.ethers.getContractFactory("UsingSafeMathExternal");
      } catch (e) {
        thrownError = true;
      }
      expect(thrownError).to.be.true;
      // The `deploy` function will throw a client-side JavaScript error (reject a promise)
      // if libraries are not linked. We use `rejectedWith` to catch this.
      // await expect(contractFactory.deploy()).to.be.rejected;
    });

    it("should deploy and work correctly when linked", async function () {
      // This test is now somewhat redundant since the fixture handles linking,
      // but it's a good example of how to do it manually.
      const libraryFactory = await hre.ethers.getContractFactory(
        "MyExternalSafeMath"
      );
      const deployedLibrary = await libraryFactory.deploy();
      await deployedLibrary.waitForDeployment();
      const libraryAddress = await deployedLibrary.getAddress();

      const contractFactory = await hre.ethers.getContractFactory(
        "UsingSafeMathExternal",
        {
          libraries: {
            "contracts/library/my_external_safe_math.sol:MyExternalSafeMath":
              libraryAddress,
          },
        }
      );

      const deployedContract = await contractFactory.deploy();
      expect(await deployedContract.doIdentity(123)).to.equal(123);
    });
  });
});
