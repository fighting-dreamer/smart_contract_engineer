// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.26;

import "hardhat/console.sol";

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

    // mapping(address => uint256) public orderNumMap;
    // mapping(address => mapping(uint256 => OrderState)) public userOrderMap;
    // mapping(uint256 => string) orderDetails;
    // TODO: this orderStates is not ot be used 
    // but it s here coz i have operations i want to run on mapping stateTransitionMap
    // how ot make it not usable or available or basically secure ?
    OrderState[] internal orderStates; 
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

    function debugGetOrderStates() external view returns (OrderState[] memory) {
        return orderStates;
    }

    function computeArrayHash(
        OrderState[] memory arr
    ) internal pure returns (bytes32) {
        uint256 enumCount = uint256(type(OrderState).max) + 1; // count the number of enums for a given enum type.
        bool[] memory seen = new bool[](enumCount);

        for (uint256 i = 0; i < arr.length; i++) {
            uint8 val = uint8(arr[i]);
            if (val < enumCount) {
                seen[val] = true;
            }
        }

        bytes memory arrAbiEncode = "";
        for (uint256 i = 0; i < enumCount; i++) {
            if (seen[i]) {
                arrAbiEncode = abi.encodePacked(arrAbiEncode, OrderState(i));
            }
        }
        return keccak256(arrAbiEncode);
    }

    function containsOrderState(
        OrderState[] memory arr,
        OrderState state
    ) internal pure returns (uint256, bool) {
        for (uint i = 0; i < arr.length; i++) {
            if (arr[i] == state) {
                return (i, true);
            }
        }
        return (0, false);
    }

    function printArray(OrderState[] memory _orderStates) internal pure{
        for (uint i = 0; i < _orderStates.length; i++) {
            console.log(uint256(_orderStates[i]));
        }
        console.log("\n");
    }

    function removeOrderState(
        OrderState[] storage _orderStates,
        uint256 index
    ) internal {
        
        require(index < _orderStates.length, "Invalid index");
        _orderStates[index] = _orderStates[_orderStates.length - 1];
        _orderStates.pop();
    }

    function areSameNextStates(
        OrderState[] memory currNextStates,
        OrderState[] memory nextStates
    ) internal pure returns (bool) {
        bool isLengthSame = currNextStates.length == nextStates.length;
        if (!isLengthSame) return false;
        bool isSameArrayHash = computeArrayHash(currNextStates) ==
            computeArrayHash(nextStates);
        return isSameArrayHash;
    }

    function updateStateTransitionMapping(
        OrderState currState,
        OrderState[] calldata nextStates
    ) external {
        // if the nextStates are alredy added => if their length and hashes are same => do nothing
        // if the nextStates are already added => if their length and hashes are same => do nothing
        if (!areSameNextStates(stateTransitionMap[currState], nextStates)) {
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

    function getStateTransitionMap(OrderState state) external view returns (OrderState[] memory) {
        return stateTransitionMap[state];
    }
}
