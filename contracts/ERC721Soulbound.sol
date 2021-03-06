// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./brightid/extensions/BrightIDRegistryAddress.sol";

contract ERC721Soulbound is ERC721, BrightIDRegistryAddress {
    constructor(
        address verifier,
        bytes32 context,
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) BrightIDRegistryAddress(verifier, context) {}

    /**
     * @dev See {ERC721-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - `from` and `to` must belong to the same BrightID.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);
        // Ignore transfers during minting
        if (from == address(0)) {
            return;
        }
        require(
            _isSameBrightID(from, to),
            "ERC721Soulbound: Not linked to the same BrightID"
        );
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        virtual
        override
        returns (bool)
    {
        require(
            _exists(tokenId),
            "ERC721: operator query for nonexistent token"
        );
        address owner = ERC721.ownerOf(tokenId);
        return _isSameBrightID(spender, owner);
    }
}
