// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

contract Counter {
    address private owner;
    uint256 public number;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not Owner");
        _;
    }

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }
}
