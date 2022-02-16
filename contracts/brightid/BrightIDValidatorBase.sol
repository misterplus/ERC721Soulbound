// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract BrightIDValidatorBase is Ownable {

    // Address of trusted verifier
    address internal _verifier;

    // Context of BrightID app
    bytes32 internal _context;

    /**
     * @dev Emitted when `_verifier` is set to `verifier`.
     */
    event VerifierSet(address verifier);

    /**
     * @dev Emitted when `_context` is set to `context`.
     */
    event ContextSet(bytes32 context);

    constructor(address verifier, bytes32 context) {
        _verifier = verifier;
        _context = context;
    }

    /**
     * @dev Set `_context` to `context`.
     *
     * Requirements:
     *
     * - the caller must be the owner.
     *
     * Emits a {ContextSet} event.
     */
    function setContext(bytes32 context) external onlyOwner {
        _context = context;
        emit ContextSet(context);
    }

    /**
     * @dev Set `_verifier` to `verifier`.
     *
     * Requirements:
     *
     * - the caller must be the owner.
     *
     * Emits a {VerifierSet} event.
     */
    function setVerifier(address verifier) external onlyOwner {
        _verifier = verifier;
        emit VerifierSet(verifier);
    }
}