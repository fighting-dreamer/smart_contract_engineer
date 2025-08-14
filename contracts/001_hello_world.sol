// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

contract HelloWorld {
    event UpdatedGreetingMessage(address indexed sender, string message);
    event Transfer(address indexed from, address indexed to, uint256 value);

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

    receive() external payable {
        emit Transfer(msg.sender, address(this), msg.value);
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