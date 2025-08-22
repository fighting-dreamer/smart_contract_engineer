// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "./004_enums.sol";

contract TestLearningEnums is LearnEnums {
    function testComputeArrayHash(OrderState[] calldata arr) public pure returns (bytes32) {
        return computeArrayHash(arr);
    }
}