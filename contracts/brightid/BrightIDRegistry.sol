// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BrightIDRegistry is Ownable {
    // BrightID Verification data
    struct Verification {
        uint256 time;
        address[] contextIds;
    }

    // Contract address of verifier token
    IERC20 private _verifierToken;

    // Context of BrightID app
    bytes32 private _context;

    // Mapping address to the according verification data
    mapping(address => Verification) internal verifications;

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
        require(verifications[_msgSender()].time > 0, "BrightIDRegistry: caller is not verified");
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
        address[] memory contextIds,
        uint256 timestamp,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(
            verifications[contextIds[0]].time < timestamp,
            "BrightIDRegistry: Newer verification registered before"
        );

        bytes32 message = keccak256(
            abi.encodePacked(_context, contextIds, timestamp)
        );
        address signer = ecrecover(message, v, r, s);
        require(
            _verifierToken.balanceOf(signer) > 0,
            "BrightIDRegistry: Signer is not authorized"
        );

        for (uint256 i = 0; i < contextIds.length; i++) {
            verifications[contextIds[i]].time = timestamp;
            verifications[contextIds[i]].contextIds = contextIds;
        }
    }

    /**
     * @dev Returns `true` if `contextId` has been registered
     */
    function isVerified(address contextId) external view returns (bool) {
        return verifications[contextId].time > 0;
    }
}
