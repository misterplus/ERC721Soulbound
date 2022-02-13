// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./../BrightIDRegistryBase.sol";

/**
 * @dev Hex address based implementation of {BrightIDRegistryBase}.
 */
contract BrightIDRegistryAddress is BrightIDRegistryBase {
    // Mapping address to the according verification data
    mapping(address => Verification) internal verifications;

    // Mapping verification data to the member addresses
    mapping(bytes32 => address[]) internal members;

    /**
     * @dev Throws if caller is not verified.
     */
    modifier onlyVerified() {
        require(
            verifications[_msgSender()].time > 0,
            "BrightIDRegistryAddress: caller is not verified"
        );
        _;
    }

    constructor(IERC20 verifierToken, bytes32 context)
        BrightIDRegistryBase(verifierToken, context)
    {}

    /**
     * @dev Register BrightID verification data.
     *
     * Requirements:
     *
     * - `timestamp` must be greater than the previous timestamp.
     * - the signature must be valid under the context `_context`.
     * - the signature must be signed by a valid node.
     *
     * @param contextIds History of contextIds used by this user under the context `_context`
     * @param timestamp Verification timestamp
     * @param v Component of signature
     * @param r Component of signature
     * @param s Component of signature
     */
    function register(
        address[] calldata contextIds,
        uint256 timestamp,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(
            verifications[contextIds[0]].time < timestamp,
            "BrightIDRegistryAddress: Newer verification registered before"
        );

        bytes32 message = keccak256(
            abi.encodePacked(_context, contextIds, timestamp)
        );
        address signer = ecrecover(message, v, r, s);
        require(
            _verifierToken.balanceOf(signer) > 0,
            "BrightIDRegistryAddress: Signer is not authorized"
        );

        members[message] = contextIds;
        for (uint256 i = 0; i < contextIds.length; i++) {
            verifications[contextIds[i]].time = timestamp;
            verifications[contextIds[i]].message = message;
        }
    }

    /**
     * @dev See {BrightIDRegistryBase-isVerified}.
     */
    function isVerified(address addr) external view override returns (bool) {
        return verifications[addr].time > 0;
    }

    /**
     * @dev See {BrightIDRegistryBase-_isSameBrightID}.
     */
    function _isSameBrightID(address first, address second)
        internal
        view
        override
        returns (bool)
    {
        return
            verifications[first].time > 0 &&
            verifications[first].message == verifications[second].message;
    }
}
