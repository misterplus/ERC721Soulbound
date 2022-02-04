// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./brightid/BrightIDRegistry.sol";

contract ERC721Soulbound is ERC721, BrightIDRegistry {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdTracker;

    constructor(
        IERC20 verifierToken,
        bytes32 context,
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) BrightIDRegistry(verifierToken, context) {}

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
    function mint() external onlyVerified {
        for (uint i = 0; i < verifications[_msgSender()].contextIds.length; i++) {
            require(balanceOf(verifications[_msgSender()].contextIds[i]) == 0, "ERC721Soulbound: This BrightID had minted");
        }
        _mint(_msgSender(), _tokenIdTracker.current());
        _tokenIdTracker.increment();
    }

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
        bool same = false;
        for (uint256 i = 0; i < verifications[from].contextIds.length; i++) {
            if (verifications[from].contextIds[i] == to) {
                same = true;
                break;
            }
        }
        require(same, "ERC721Soulbound: Not linked to the same BrightID");
    }
}
