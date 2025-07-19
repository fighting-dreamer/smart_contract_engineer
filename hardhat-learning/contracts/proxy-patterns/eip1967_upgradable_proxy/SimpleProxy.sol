// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

// https://rareskills.io/post/proxy-contract#how-to-deploy-an-upgradeable-smart-contract-not-for-production
// Not Production grade
// Bugs or Issues : 
// cant do : if the admin wants to call setImplementation of actual implementation contract, not the proxy one.
// 
contract SimpleProxy {
    // ERC-1967 :
    // we want admin in specific slot that is not oging to be over-ridden
    // we want implementation in specific slot that is not going to be over-ridden

    /**
     * @dev Storage slot for the implementation address.
     * This is derived from `bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1)`.
     */
    bytes32 private constant _IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    /**
     * @dev Storage slot for the admin address.
     * This is derived from `bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1)`.
     */
    bytes32 private constant _ADMIN_SLOT =
        0xb53127684a568b3173ae13b9f8a6016eaf15eb9e8e9f03347e2db6a3ec1e1cb0;

    constructor() {
        address admin = msg.sender;
        assembly {
            sstore(_ADMIN_SLOT, admin)
        }
    }

    modifier onlyOwner() {
        address admin;
        assembly {
            admin := sload(_ADMIN_SLOT)
        }
        require(admin == msg.sender, "Not the contract Owner");
        _;
    }

    function setImplementation(address _implementation) external onlyOwner {
        assembly {
            sstore(_IMPLEMENTATION_SLOT, _implementation)
        }
    }

    fallback(bytes calldata data) external returns (bytes memory) {
        address implementation;
        assembly {
            implementation := sload(_IMPLEMENTATION_SLOT)
        }
        require(implementation != address(0), "Implementation not set");

        (bool success, bytes memory result) = implementation.delegatecall(data);
        require(success, "Delegate Call Failed");
        return result;
    }
}
