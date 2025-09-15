// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {HelloWorld} from "../src/HelloWorld.sol";

contract HelloWorldTest is Test {
    HelloWorld public hw;
    string public testMessage= "test Message";

    function setUp() public {
        hw = new HelloWorld();
        hw.setMessage(testMessage);
    }

    function test_get() public view {
        assertEq(hw.get(), testMessage);
    }
}
