// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Variables {
    // state variables
    string public text = "Hello";
    uint256 public num = 123;

    function doSomething() public view {
        // local variables
        uint256 _i = 456;

        // global variables : block etc...
        uint256 _blockTimestamp = block.timestamp;
        address _sender = msg.sender; // address of caller
    }
}