// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

contract ImplementationEIP1967Three {
    uint256 public number;
    uint256 public delta;

    function decrement() external {
        number = number - delta;
    }

    function multiply(uint256 _input) external returns(uint256) {
        number = number * delta * _input;
        return number;
    }
}