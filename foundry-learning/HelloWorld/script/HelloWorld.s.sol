// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {HelloWorld} from "../src/HelloWorld.sol";

contract HelloWorldScript is Script {
    HelloWorld public hw;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        hw = new HelloWorld();

        vm.stopBroadcast();
    }
}
