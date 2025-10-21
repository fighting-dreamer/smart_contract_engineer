// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

contract MinimalProxyOne {
    address immutable implementation;
    constructor(address _implementation) {
        implementation = _implementation;
    }

    fallback(bytes calldata data) external payable returns (bytes memory) {
        (bool success, bytes memory result) = implementation.delegatecall(data);
        require(success, "DelegateCall Failed");
        return result;
    }
}