// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

contract ImplementationEIP1967Two {
    uint256 public number;

    function increment() external {
        number = number + 1;
    }

    function decrement() external {
        number = number - 1;
    }

    function multiply(uint256 _input) external {
        number = number *_input;
    }
}