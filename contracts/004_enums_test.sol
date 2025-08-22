// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "./004_enums.sol";

contract TestLearningEnums is LearnEnums {
    function testComputeArrayHash(
        OrderState[] calldata arr
    ) public pure returns (bytes32) {
        return computeArrayHash(arr);
    }

    function testContainsOrderState(
        OrderState[] calldata arr,
        OrderState state
    ) public pure returns (uint256, bool) {
        return containsOrderState(arr, state);
    }

    function testRemoveOrderState(OrderState[] calldata _inputOrderStates, uint256 _index) public returns(OrderState[] memory) {
        orderStates = _inputOrderStates;
        removeOrderState(orderStates, _index);
        return orderStates;
    }
}
