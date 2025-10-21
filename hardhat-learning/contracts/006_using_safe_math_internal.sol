// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "./library/my_safe_math.sol";

contract UsingSafeMathInternal {
    // using MySafeMath;

    function doAddition(uint256 a, uint256 b) public pure returns (uint256) {
        return MySafeMath.add(a, b);
    }

    function doSubtraction(uint256 a, uint256 b) public pure returns (uint256) {
        return MySafeMath.sub(a, b);
    }
}