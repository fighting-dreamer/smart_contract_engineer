// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "./library/my_external_safe_math.sol";

contract UsingSafeMathExternal {
    // using MyExternalSafeMath;

    function doAddition(uint256 a, uint256 b) public pure returns (uint256) {
        return MyExternalSafeMath.add(a, b);
    }

    function doSubtraction(uint256 a, uint256 b) public pure returns (uint256) {
        return MyExternalSafeMath.sub(a, b);
    }

    // If you dont use the external or public functions of library, you dont have to link.
    function doIdentity(uint256 a) public pure returns (uint256) {
        return MyExternalSafeMath.identity(a);
    }
}