// SPDX-License-Identifier: MIT

import {SomeContract} from "./SomeContract.sol";

pragma solidity ^0.8.26;

// create2 : deterministically compute address of the contract
contract DeployusingCreate2 {
    // Create2 : the address for ethereum contract is deterministically computed form the address of its creator(sender) and how many transactions creator have sent(nonce).
    // the sender and nonce are RLP encoded and then hashed using keccak-256
    event DeployusingCreate2Event(address addr, uint _salt);

    function getByteCode(address _owner, uint256 _value) public pure returns (bytes memory) {
        bytes memory byteCode = type(SomeContract).creationCode;
        return abi.encodePacked(byteCode, abi.encode(_owner, _value)); // owner and value are contructor params of "SomeContract" whose "creation-code" we are using.
    }

    function getAddress(bytes memory byteCode, uint256 _salt) public view returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this), // the factory contract or deployer of contract.
                _salt,
                keccak256(byteCode)
            )
        );

        return address(uint160(uint256(hash)));
    }

    function deploy(bytes memory _byteCode, uint256 _salt) public payable {
        address addr;
        /*
            How to use create2 : 
            create2(v, p, n, s)
            v : amount of ETH to send
            p : pointer to start of code in memory
            n : size of code
            s : salt
        */

        assembly {
            addr :=
                create2(
                    callvalue(), // wei sent with current call
                    add(_byteCode, 0x20), // actual code start after first 32 bytes, 0x20 is 32 bytes in nhex
                    mload(_byteCode), // load size of code contract, its contained in first 32 bytes
                    _salt
                )
            if iszero(extcodesize(addr)) { revert(0, 0) }
        }

        emit DeployusingCreate2Event(addr, _salt);
    }
}
