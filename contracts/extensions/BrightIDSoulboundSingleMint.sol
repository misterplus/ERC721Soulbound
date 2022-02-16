// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "../BrightIDSoulbound.sol";

abstract contract BrightIDSoulboundSingleMint is BrightIDSoulbound {
    /**
     * @dev Creates a new token for the caller.
     *
     * See {ERC721-_mint}.
     *
     * Requirements:
     *
     * - the caller must be verified.
     * - the token balance of all contextIds associated with the caller BrightID must be zero.
     */
    function mint(
        bytes32[] calldata contextIds,
        uint256 timestamp,
        uint256 tokenId,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        _validate(contextIds, timestamp, v, r, s);
        uint256 balance;
        for (uint256 i = 0; i < contextIds.length; i++) {
            balance += BrightIDSoulbound.balanceOf(_uuidToAddress[hashUUID(contextIds[i])]);
        }
        require(balance == 0, "BrightIDSoulboundSingleMint: This BrightID had minted");
        _safeMint(_uuidToAddress[hashUUID(contextIds[0])], tokenId);
    }
}
