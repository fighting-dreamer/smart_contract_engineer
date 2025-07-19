import {loadFixture} from '@nomicfoundation/hardhat-toolbox/network-helpers';
import hre, {ethers} from 'hardhat';
import {expect} from 'chai';

import {TaskListApp} from '../typechain';

describe('TaskListApp', function () {
  async function deployTaskListAppFixture() {
    const TaskListAppFactory = await hre.ethers.getContractFactory('TaskListApp');
    
    const taskAppListDeployed = (await TaskListAppFactory.deploy()) as unknown as TaskListApp;
    await taskAppListDeployed.waitForDeployment();
    const [account, otherAccount] = await hre.ethers.getSigners();

    return {
      taskAppListDeployed,
      account,
      otherAccount,
    };
  }

  it('should have zero tasks initially', async function () {
    const {taskAppListDeployed} = await loadFixture(deployTaskListAppFixture);
    const tasks = await taskAppListDeployed.getTasks();
    expect(tasks.length).to.equal(0);
  });

  it('should store a new task and have a length of one', async function () {
    const {taskAppListDeployed} = await loadFixture(deployTaskListAppFixture);
    const taskMessage = 'qwerty';
    const txn = await taskAppListDeployed.addTask(taskMessage);
    await txn.wait();

    const tasks = await taskAppListDeployed.getTasks();

    expect(tasks.length).to.equal(1);

    // Correctly assert the message property of the struct
    expect(tasks[0].message).to.equal(taskMessage);
  });
});
