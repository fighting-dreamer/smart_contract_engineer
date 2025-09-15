// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract HelloWorld {
    string private message;

    constructor() {}

    function setMessage(string calldata _message) external returns(string memory) {
        message = _message;
        return message;
    }

    function get() external view returns(string memory) {
        return message;
    }
}
