// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

// link : https://rareskills.io/post/proxy-contract#how-to-deploy-an-upgradeable-smart-contract-not-for-production
// Bugs : 
// 1. storage collision possible.
// implementation can change its own storage slot or admin;s value or data itself.

contract BuggyProxy {
    address public implementation;
    address public admin;
    uint256 public counter;
    constructor() {
        admin = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == admin, "Not Contract Owner");
        _;
    }

    function setImplementation(address _implementation) external onlyOwner returns(address) {
        implementation = _implementation;
    }

    fallback(bytes calldata data) external  returns (bytes memory) {
        require(implementation != address(0), "Implementation not set");
        (bool success, bytes memory result) = implementation.delegatecall(data);
        require(success, "Delegate Call Failed");
        return result;
    }
}