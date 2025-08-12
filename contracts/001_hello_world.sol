// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

contract HelloWorld {
    event UpdatedGreetingMessage(address indexed sender, string message);

    string public greet = "Hello World";
    constructor(string memory _greet) {
        greet = _greet;
    }

    function updateGreet(string memory _greet) public {
        greet = _greet;
        emit UpdatedGreetingMessage(msg.sender, _greet);
    }
}