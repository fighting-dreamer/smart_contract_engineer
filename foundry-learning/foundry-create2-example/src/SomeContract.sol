// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

contract SomeContract {
    address private owner;
    uint256 private value;

    constructor(address _owner, uint256 _value) {
        owner = _owner;
        value = _value;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
