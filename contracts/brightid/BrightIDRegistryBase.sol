// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract BrightIDRegistryBase is Ownable {
    // BrightID Verification data
    struct Verification {
        uint256 time;
        bytes32 message;
    }

    // Contract address of verifier token
    IERC20 internal _verifierToken;

    // Context of BrightID app
    bytes32 internal _context;

    /**
     * @dev Emitted when `_verifierToken` is set to `verifierToken`.
     */
    event VerifierTokenSet(IERC20 verifierToken);

    /**
     * @dev Emitted when `_context` is set to `context`.
     */
    event ContextSet(bytes32 context);

    constructor(IERC20 verifierToken, bytes32 context) {
        _verifierToken = verifierToken;
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
     * @dev Set `_verifierToken` to `verifierToken`.
     *
     * Requirements:
     *
     * - the caller must be the owner.
     *
     * Emits a {VerifierTokenSet} event.
     */
    function setVerifierToken(IERC20 verifierToken) external onlyOwner {
        _verifierToken = verifierToken;
        emit VerifierTokenSet(verifierToken);
    }

    /**
     * @dev Returns `true` if `addr` has been registered.
     */
    function isVerified(address addr) external view virtual returns (bool);

    /**
     * @dev Returns whether address `first` and `second` is associated with the same BrightID.
     */
    function _isSameBrightID(address first, address second)
        internal
        view
        virtual
        returns (bool);
}
