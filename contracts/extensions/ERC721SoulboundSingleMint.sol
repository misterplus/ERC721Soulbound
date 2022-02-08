// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "../ERC721Soulbound.sol";

abstract contract ERC721SoulboundSingleMint is ERC721Soulbound {

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
    function mint(uint256 tokenId) external onlyVerified {
        for (
            uint256 i = 0;
            i < members[verifications[_msgSender()].message].length;
            i++
        ) {
            require(
                balanceOf(members[verifications[_msgSender()].message][i]) == 0,
                "ERC721SoulboundSingleMint: This BrightID had minted"
            );
        }
        _safeMint(_msgSender(), tokenId);
    }
}
