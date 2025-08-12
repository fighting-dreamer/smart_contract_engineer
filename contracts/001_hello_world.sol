// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

contract HelloWorld {
    event UpdatedGreetingMessage(address indexed sender, string message);

    string public greet = "Hello World";
    address private owner;

    constructor(string memory _greet) {
        greet = _greet;
        owner = msg.sender;
    }

    modifier onlyOwnerWithRevert() {
        if (msg.sender != owner) {
            revert("Only the owner can call this function.");
        }
        _;
    }

    modifier onlyOwnerWithRequire() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function updateGreet(string memory _greet) public {
        greet = _greet;
        emit UpdatedGreetingMessage(msg.sender, _greet);
    }

    function updateGreetWithRevert(string memory _greet) onlyOwnerWithRevert() public {
        updateGreet(_greet);
    }

    function updateGreetWithRequire(string memory _greet) onlyOwnerWithRequire() public {
        updateGreet(_greet);
    }
}