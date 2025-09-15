// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract HelloWorld {
    address private owner;
    string private message;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setMessage(string calldata _message) external onlyOwner returns (string memory) {
        message = _message;
        return message;
    }

    function get() external view returns (string memory) {
        return message;
    }
}
