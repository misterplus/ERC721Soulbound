// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./../BrightIDRegistryBase.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * @dev UUID based implementation of {BrightIDRegistryBase}.
 */
contract BrightIDRegistryOwnership is BrightIDRegistryBase {
    using ECDSA for bytes32;

    // Mapping UUID to address
    mapping(bytes16 => address) internal _uuidToAddress;

    // Mapping address to UUID
    mapping(address => bytes16) internal _addressToUuid;

    constructor(IERC20 verifierToken, bytes32 context)
        BrightIDRegistryBase(verifierToken, context)
    {}

    /**
     * @dev Bind an address to an UUID.
     *
     * Requirements:
     *
     * - `uuid` must be not bound.
     * - `owner` must be not bound.
     * - `signature` must be a valid ETH signed signature.
     * - the signer of `signature` must be `owner`.
     *
     * @param owner Owner address of signature
     * @param uuid Generated UUID
     * @param nonce Generated nonce
     * @param signature Signed packed data
     */
    function bind(
        address owner,
        bytes16 uuid,
        uint256 nonce,
        bytes calldata signature
    ) external {
        require(
            _uuidToAddress[uuid] == address(0) &&
                _addressToUuid[owner] == bytes16(0),
            "BrightIDRegistryOwnership: UUID or address already bound"
        );
        address signer = getUUIDHash(owner, uuid, nonce)
            .toEthSignedMessageHash()
            .recover(signature);
        require(
            signer != address(0) && signer == owner,
            "BrightIDRegistryOwnership: Signature invalid"
        );
        _uuidToAddress[uuid] = owner;
        _addressToUuid[owner] = uuid;
    }

    /**
     * @dev Register BrightID verification data.
     *
     * Requirements:
     *
     * - `timestamp` must be greater than the previous timestamp.
     * - the signature must be valid under the context `_context`.
     * - the signature must be signed by a valid node.
     * - `contextIds` must all be bound.
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
            _contents[_verifications[_uuidToAddress[contextIds[0]]]].time <
                timestamp,
            "BrightIDRegistryOwnership: Newer verification registered before"
        );

        bytes32 message = keccak256(
            abi.encodePacked(_context, contextIds, timestamp)
        );
        address signer = message.recover(v, r, s);
        require(
            _verifierToken.balanceOf(signer) > 0,
            "BrightIDRegistryOwnership: Signer not authorized"
        );
        _contents[message].time = timestamp;
        _contents[message].members = new address[](contextIds.length);
        address addr;
        for (uint256 i = 0; i < contextIds.length; i++) {
            addr = _uuidToAddress[contextIds[i]];
            require(
                addr != address(0),
                "BrightIDRegistryOwnership: UUID not bound"
            );
            _contents[message].members[i] = addr;
            _verifications[addr] = message;
        }
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
}
