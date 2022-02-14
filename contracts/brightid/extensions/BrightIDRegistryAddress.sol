// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./../BrightIDRegistryBase.sol";

/**
 * @dev Hex address based implementation of {BrightIDRegistryBase}.
 */
contract BrightIDRegistryAddress is BrightIDRegistryBase {
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
            _contents[_verifications[contextIds[0]]].time < timestamp,
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
        for (uint256 i = 0; i < contextIds.length; i++) {
            _verifications[contextIds[i]] = message;
        }
        _contents[message].time = timestamp;
        _contents[message].members = contextIds;
    }
}
