// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import "hardhat/console.sol";

contract Operations {
    // hardhat console
    // conditionals
    // loops
    // array operations
    // mapping operations
    // enum poerations


    uint256 public myNumber = 123;
    address public myAddress = msg.sender;
    uint256[] public myArray; // A dynamic array
    mapping(uint256 => uint256) public myMapping;

    constructor() {
        // Let's add some initial data for demonstration
        myArray.push(10);
        myArray.push(20);
        myMapping[1] = 100;
    }

    function addToArray(uint256 _value) external {
        myArray.push(_value);
    }

    function addToMapping(uint256 _key, uint256 _value) external {
        myMapping[_key] = _value;
    }

    function printArray() public view {
        console.log("--- Logging Array Contents ---");
        for (uint i = 0; i < myArray.length; i++) {
            // Log each element with its index
            console.log("myArray[%d]:", i, myArray[i]);
        }
    }

    function print() public view {
        console.log("--- Logging from Solidity ---");
        console.log("myNumber:", myNumber);
        console.log("myAddress:", myAddress);
        // console.log("myArray : ", myArray); // does not
        printArray();
        // To log from a mapping, you must access a specific key.
        console.log("myMapping[1]:", myMapping[1]);
    }

    function simpleIfElse() internal view {
        if(myNumber > 10) {
            console.log("myNumber is greater than 10");
        }else {
            console.log("my number is less than or equal 10");
        }
    }

    function terneryConditional() internal view returns (string memory) {
        return myNumber > 100 ? "Yes" : "No";
    }

    function checkConditionals() public view returns(string memory){
        simpleIfElse();
        string memory res = terneryConditional();
        console.log("res : ", res);
        return res;
    }
}
