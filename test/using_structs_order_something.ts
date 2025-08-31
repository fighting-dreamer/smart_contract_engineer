import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import hre from "hardhat";

describe("Testing Structs and FoodOrdering somrthing", async function () {
  async function deployContractFixture() {
    const [account, otherAccount] = await hre.ethers.getSigners();
    const contractFactory = await hre.ethers.getContractFactory(
      "OrderAccounting"
    );
    const deployedContract = await contractFactory.deploy();

    await deployedContract.waitForDeployment();

    return {
      account,
      otherAccount,
      contractFactory,
      deployedContract,
    };
  }

  it("add OrderFood", async function () {
    const { account, otherAccount, deployedContract } = await loadFixture(
      deployContractFixture
    );

    const _foodOrderTxn = await deployedContract.addNewOrder(
      1001,
      {
        orderNum: 10001,
        itemList: [
          {
            itemId: 1,
            itemName: "pizza",
            price: 10000,
          },
        ],
        userId: 1001,
        resturantId: 101,
      },
      {
        value: hre.ethers.parseEther("0.05"), // Here you specify the amount of Ether to send
      }
    );

    console.log(JSON.stringify(_foodOrderTxn));
    const foodORderReciept = await _foodOrderTxn.wait();
    console.log(foodORderReciept);

    const foodOrderObj = await deployedContract.getUserOrderInfo(1001, 1);
    console.log(foodOrderObj);
  });
});
