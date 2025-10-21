// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

contract Counter {
    uint256 private count;

    constructor() {
        count = 0;
    }

    function get() public view returns (uint256) {
        return count;
    }

    function inc() external returns (uint256) {
        count += 1;
        return count;
    }

    function dec() external returns (uint256) {
        count -= 1;
        return count;
    }
}
