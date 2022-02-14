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
        address[] storage members = _getMembers(_msgSender());
        uint256 balance;
        for (uint256 i = 0; i < members.length; i++) {
            balance += ERC721.balanceOf(members[i]);
        }
        require(
            balance == 0,
            "ERC721SoulboundSingleMint: This BrightID had minted"
        );
        _safeMint(_msgSender(), tokenId);
    }
}
