// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

contract LearnEnums {
    // Enums are a way to create user-defined types that can represent a finite set of constant values.
    // They are useful for state machines, tracking statuses, etc.
    // They are implicitly convertible to and from integers.
    enum OrderState {
        PLACED, // Default value, index 0
        CONFIRMED, // 1
        PREPARED, // 2
        ASSIGNED, // 3
        ON_THE_WAY, // 4
        DELIVERED, // 5
        CANCELLED, // 6
        TERMINATED, // 7
        REFUNDED // 8
    }

    mapping(address => mapping(uint256 => OrderState)) public userOrderMap;
    mapping(uint256 => string) orderDetails;
    mapping(OrderState => OrderState[]) public stateTransitionMap;

    event OrderStateChanged(
        address indexed user,
        uint256 orderId,
        OrderState newState
    );

    constructor() {
        stateTransitionMap[OrderState.PLACED] = [OrderState.CONFIRMED];
        stateTransitionMap[OrderState.CONFIRMED] = [
            OrderState.ASSIGNED,
            OrderState.PREPARED,
            OrderState.CANCELLED
        ];
        stateTransitionMap[OrderState.PREPARED] = [
            OrderState.ASSIGNED,
            OrderState.CANCELLED
        ];
        stateTransitionMap[OrderState.ASSIGNED] = [OrderState.ON_THE_WAY];
        stateTransitionMap[OrderState.ON_THE_WAY] = [OrderState.DELIVERED];
        stateTransitionMap[OrderState.CANCELLED] = [
            OrderState.REFUNDED,
            OrderState.TERMINATED
        ];
    }

    function computeArrayHash(OrderState[] arr) internal pure returns (bytes4) {
        uint enumCount = uint(type(OrderState).max) + 1; // count hte number of enums ofr a given enum type.
        uint j = 0;
        bytes memory arrAbiEncode = "";
        for (uint i = 0; i < enumCount; i++) {
            if (j < arr.length && arr[j] == OrderState(i)) {
                arrAbiEncode = abi.encodePacked(arrAbiEncode, arr[j]);
                j++;
            }
        }
        return keccak256(arrAbiEncode);
    }

    function containsOrderState(
        OrderState[] arr,
        OrderState state
    ) internal pure returns (uint256, bool) {
        for (uint i = 0; i < arr.length; i++) {
            if (arr[i] == state) {
                return (i, true);
            }
        }
        return (0, false);
    }

    function getNextStatesTransitionMapping(
        OrderState currState
    ) internal pure returns (OrderState[]) {
        return stateTransitionMap[currState];
    }

    function areSameNextStates(
        OrderState[] currNextStates,
        OrderState[] nextStates
    ) internal pure returns (bool) {
        bool isLengthSame = currNextStates.length == nextStates.length;
        if (!isLengthSame) return false;
        bool isSameArrayHash = computeArrayHash(currNextStates) ==
            computeArrayHash(nextStates);
        return isSameArrayHash;
    }

    function updateStateTransitionMapping(
        OrderState currState,
        OrderState[] nextStates
    ) external {
        // if the nextStates are alredy added => if their length and hashes are same => do nothing
        if (!areSameNextStates(currState, nextStates)) {
            stateTransitionMap[currState] = nextStates;
        }
    }
    function addOrderStateInTransitionMapping(
        OrderState currState,
        OrderState nextState
    ) external {
        // if the transition mapping already have the next State in it as in adding a duplicate entry in the array.
        (, bool ok) = containsOrderState(
            stateTransitionMap[currState],
            nextState
        );
        if (!ok) {
            stateTransitionMap[currState].push(nextState);
        }
    }

    function removeOrderStateTransitionMapping(
        OrderState currState,
        OrderState removableState
    ) external {
        (uint256 index, bool ok) = containsOrderState(
            stateTransitionMap[currState],
            removableState
        );
        if (ok) {
            removeOrderState(stateTransitionMap[currState], index);
        }
    }
}
