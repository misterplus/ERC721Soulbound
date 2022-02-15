// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract BrightIDRegistryBase is Ownable {
    // BrightID Verification data
    struct Verification {
        uint256 time;
        address[] members;
    }

    // Address of trusted verifier
    address internal _verifier;

    // Context of BrightID app
    bytes32 internal _context;

    // Mapping address to packed verification data
    mapping(address => bytes32) internal _verifications;

    // Mapping packed verification data to unpacked contents
    mapping(bytes32 => Verification) internal _contents;

    /**
     * @dev Emitted when `_verifier` is set to `verifier`.
     */
    event VerifierSet(address verifier);

    /**
     * @dev Emitted when `_context` is set to `context`.
     */
    event ContextSet(bytes32 context);

    /**
     * @dev Throws if caller is not verified.
     */
    modifier onlyVerified() {
        require(
            _verifications[_msgSender()] != bytes32(0),
            "BrightIDRegistryOwnership: caller not verified"
        );
        _;
    }

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

    /**
     * @dev Returns `true` if `addr` has been registered.
     */
    function isVerified(address addr) external view returns (bool) {
        return _verifications[addr] != bytes32(0);
    }

    /**
     * @dev Returns whether address `first` and `second` is associated with the same BrightID.
     */
    function _isSameBrightID(address first, address second)
        internal
        view
        returns (bool)
    {
        return
            _verifications[first] != bytes32(0) &&
            _verifications[first] == _verifications[second];
    }

    /**
     * @dev Returns an array of addresses associated with the same BrightID as `addr`.
     */
    function _getMembers(address addr)
        internal
        view
        returns (address[] storage)
    {
        return _contents[_verifications[addr]].members;
    }
}
