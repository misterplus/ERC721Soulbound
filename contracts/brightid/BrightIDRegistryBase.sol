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

    // Mapping address to the according verification data
    mapping(address => Verification) internal _verifications;

    // Mapping verification data to the member addresses
    mapping(bytes32 => address[]) internal _members;

    /**
     * @dev Emitted when `_verifierToken` is set to `verifierToken`.
     */
    event VerifierTokenSet(IERC20 verifierToken);

    /**
     * @dev Emitted when `_context` is set to `context`.
     */
    event ContextSet(bytes32 context);

    /**
     * @dev Throws if caller is not verified.
     */
    modifier onlyVerified() {
        require(
            _verifications[_msgSender()].time > 0,
            "BrightIDRegistryOwnership: caller is not verified"
        );
        _;
    }

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
    function isVerified(address addr) external view returns (bool) {
        return _verifications[addr].time > 0;
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
            _verifications[first].time > 0 &&
            _verifications[first].message == _verifications[second].message;
    }

    /**
     * @dev Returns an array of addresses associated with the same BrightID as `addr`.
     */
    function _getMembers(address addr)
        internal
        view
        returns (address[] memory)
    {
        return _members[_verifications[addr].message];
    }
}
