// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./../BrightIDRegistryBase.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * @dev Hex address based implementation of {BrightIDRegistryBase}.
 * 
 * @notice UUID based implementation should be preferred due to the unique nature of context ids, see {BrightIDRegistryOwnership}.
 */
contract BrightIDRegistryAddress is BrightIDRegistryBase {

    using ECDSA for bytes32;

    constructor(address verifier, bytes32 context)
        BrightIDRegistryBase(verifier, context)
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
        address signer = message.recover(v, r, s);
        require(
            _verifier == signer,
            "BrightIDRegistryAddress: Signer not authorized"
        );
        for (uint256 i = 0; i < contextIds.length; i++) {
            _verifications[contextIds[i]] = message;
        }
        _contents[message].time = timestamp;
        _contents[message].members = contextIds;
    }
}
