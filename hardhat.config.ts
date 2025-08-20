import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, HardhatUserConfig } from "hardhat/types";
import { ethers } from "ethers";
import "@nomicfoundation/hardhat-ethers";
import "@nomicfoundation/hardhat-chai-matchers";
import "@typechain/hardhat";

import "./tasks/compile_files";

task(
  "accounts",
  "Prints the list of accounts and their private keys"
).setAction(async (taskArgs: any, hre: HardhatRuntimeEnvironment) => {
  const networkConfig = hre.config.networks.hardhat;

  // Check if the accounts are configured
  if (!networkConfig || !networkConfig.accounts) {
    console.error("No accounts found in the Hardhat network configuration.");
    return;
  }

  let privateKeys: string[] = [];

  // Check if the accounts are configured as an HD Wallet (mnemonic)
  if ("mnemonic" in networkConfig.accounts) {
    const hdAccounts = networkConfig.accounts;
    const numAccounts = 20; // Hardhat's default number of accounts

    for (let i = 0; i < numAccounts; i++) {
      // Use the new ethers.js v6 method to generate a wallet from the mnemonic
      const hdNode = ethers.HDNodeWallet.fromMnemonic(
        ethers.Mnemonic.fromPhrase(hdAccounts.mnemonic),
        `${hdAccounts.path}/${i}`
      );
      privateKeys.push(hdNode.privateKey);
    }
  }
  // Check if the accounts are configured as an array of private keys
  else if (Array.isArray(networkConfig.accounts)) {
    privateKeys = networkConfig.accounts.map((acc) => acc.privateKey);
  }
  // Handle the case where a single account is configured as an object
  else if ("privateKey" in networkConfig.accounts) {
    privateKeys.push(networkConfig.accounts.privateKey);
  } else {
    console.error(
      "Unsupported account configuration. Please check your hardhat.config.ts."
    );
    return;
  }

  // Now, iterate and print the addresses and private keys
  const signers = await hre.ethers.getSigners();
  for (let i = 0; i < signers.length; i++) {
    console.log("--------------------------------------------------");
    console.log(`Address: ${signers[i].address}`);
    console.log(`Private Key: ${privateKeys[i]}`);
  }
});
const config: HardhatUserConfig = {
  solidity: "0.8.26",
};

export default config;
