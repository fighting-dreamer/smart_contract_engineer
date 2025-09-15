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
    function test_setMessageWithOwnerSuccess() public {
        string memory someMessage = "someMessage";
        hw.setMessage(someMessage);
        assertEq(hw.get(), someMessage, "Owner should be able to set the message");
    }

    function test_setMessageWithNotOwnerFails() public {
        address otherAccount = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
        string memory someMessage = "some Message";
        vm.expectRevert();
        vm.prank(otherAccount);
        hw.setMessage(someMessage);
    }
}
