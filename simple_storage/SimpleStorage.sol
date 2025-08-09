// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SimpleStorage {
    event MessageStored(address from, uint128 messageIndex);

    string[] public messages;

    constructor() {}

    function store(string memory message) public {
        messages.push(message);
        emit MessageStored(msg.sender, uint128(messages.length));
    }
}
