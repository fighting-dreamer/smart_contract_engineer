// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

contract ImplementationEIP1967One {
    uint256 public number;

    function increment() external {
        number = number + 1;
    }
}