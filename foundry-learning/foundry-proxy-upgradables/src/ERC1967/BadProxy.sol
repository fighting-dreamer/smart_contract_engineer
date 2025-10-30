// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

contract BadProxy {
    address private admin;
    address private implementation;

    event AdminChanged(address indexed prevAdmin, address indexed newAdmin);
    constructor() {
        admin = msg.sender;
    }

    function changeAdmin(address _newAdmin) public {
        require(msg.sender == admin, "Not Admin");
        require(_newAdmin != address(0), "Invalid new Admin");
        admin = _newAdmin;

        emit AdminChanged(msg.sender, admin);
    }

    fallback(bytes calldata _data) external payable returns (bytes memory) {
        (bool ok, bytes memory returnData) = implementation.delegatecall(_data);

        if(ok) {
            return returnData;
        } else {
            assembly {
                revert(add(returnData, 32), mload(returnData))
            }
        }
    } 
}