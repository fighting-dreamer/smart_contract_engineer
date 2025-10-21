// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

contract CounterImplementation {
    uint256 public counter;

    function inc() external {
        counter = counter + 1;
    }

    function dec() external {
        require(counter > 0, "Coutner is zero");
        counter = counter - 1;
    }
}