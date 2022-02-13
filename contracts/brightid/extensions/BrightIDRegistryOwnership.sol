// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./../BrightIDRegistryBase.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * @dev UUID based implementation of {BrightIDRegistryBase}.
 */
contract BrightIDRegistryOwnership is BrightIDRegistryBase {
    using ECDSA for bytes32;

    // Mapping uuid to the according verification data
    mapping(bytes16 => Verification) internal verifications;

    // Mapping verification data to the member uuids
    mapping(bytes32 => bytes16[]) internal members;

    // Mapping UUID to address
    mapping(bytes16 => address) internal uuidToAddress;

    // Mapping address to UUID
    mapping(address => bytes16) internal addressToUuid;

    /**
     * @dev Throws if caller is not verified.
     */
    modifier onlyVerified() {
        require(
            verifications[addressToUuid[_msgSender()]].time > 0,
            "BrightIDRegistryOwnership: caller is not verified"
        );
        _;
    }

    constructor(IERC20 verifierToken, bytes32 context)
        BrightIDRegistryBase(verifierToken, context)
    {}

    /**
     * @dev Bound an address to an UUID.
     *
     * Requirements:
     *
     * - `uuid` must be unbounded.
     * - `signature` must be a valid ETH signed signature.
     * - the signer of `signature` must be `owner`.
     *
     * @param owner Owner address of signature
     * @param uuid Generated UUID
     * @param nonce Generated nonce
     * @param signature Signed packed data
     */
    function bound(
        address owner,
        bytes16 uuid,
        uint256 nonce,
        bytes calldata signature
    ) external {
        require(
            uuidToAddress[uuid] == address(0),
            "BrightIDRegistryOwnership: UUID already bounded"
        );
        address signer = getUUIDHash(owner, uuid, nonce)
            .toEthSignedMessageHash()
            .recover(signature);
        require(
            signer != address(0),
            "BrightIDRegistryOwnership: Unable to recover signer"
        );
        require(
            signer == owner,
            "BrightIDRegistryOwnership: Signature not owned by signer"
        );
        uuidToAddress[uuid] = owner;
        addressToUuid[owner] = uuid;
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
        bytes16[] calldata contextIds,
        uint256 timestamp,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(
            verifications[contextIds[0]].time < timestamp,
            "BrightIDRegistryOwnership: Newer verification registered before"
        );

        bytes32 message = keccak256(
            abi.encodePacked(_context, contextIds, timestamp)
        );
        address signer = ecrecover(message, v, r, s);
        require(
            _verifierToken.balanceOf(signer) > 0,
            "BrightIDRegistryOwnership: Signer is not authorized"
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
        return verifications[addressToUuid[addr]].time > 0;
    }

    /**
     * @dev Constructs and returns a hash used by this registry implementation.
     *
     * @param owner Owner address of signature
     * @param uuid Generated UUID
     * @param nonce Generated nonce
     */
    function getUUIDHash(
        address owner,
        bytes16 uuid,
        uint256 nonce
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(owner, uuid, nonce));
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
            verifications[addressToUuid[first]].time > 0 &&
            verifications[addressToUuid[first]].message ==
            verifications[addressToUuid[second]].message;
    }
}
