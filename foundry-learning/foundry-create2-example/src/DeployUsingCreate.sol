// SPDX-License-Identifier: MIT

import {Counter} from "./Counter.sol";

pragma solidity ^0.8.26;

contract DeployUsingCreate {
    event Deployed(address ctrct); // 0x1Dfb42a6eABf9869610a909Bd6D7BCf4FBB71f70 0x1Dfb42a6eABf9869610a909Bd6D7BCf4FBB71f70

    function deploy(address _owner, uint256 _salt) public {
        Counter counter = new Counter{salt: bytes32(_salt)}(_owner); // this internally using create2 as its haveing 'salt'
        emit Deployed(address(counter));
    }

    // abi.encodePAcked of `byte1(0xff) + address_of_deployer + keecak256_of_creation_bytecode_with_owner_as_argument`
    // we take the keccak256 of this encoded bytes : keeack256(abi_encoded_bytes);
    // to get the "last 20 bytes" we do this operation : address(uint160(uint256(hash)));
    function getAddressWithoutDeploying(bytes memory bytecode, uint256 _salt) public view returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), _salt, keccak256(bytecode)));

        address addr = address(uint160(uint256(hash)));
        return addr;
    }

    function getByteCode(address _owner) public pure returns (bytes memory) {
        bytes memory bytecode = type(Counter).creationCode;
        return abi.encodePacked(bytecode, abi.encode(_owner)); // we are passing owner as argument to this bytecode, otherwise if we had some other values, we have to pass that other values too
    }
}
