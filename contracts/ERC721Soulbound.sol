// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ERC721Soulbound is Context, Ownable, ERC721 {
    using Counters for Counters.Counter;

    IERC20 public verifierToken;
    bytes32 public context;

    Counters.Counter private _tokenIdTracker;

    event VerifierTokenSet(IERC20 verifierToken);
    event ContextSet(bytes32 _context);

    struct Verification {
        uint256 time;
        address[] addrs;
    }
    mapping(address => Verification) public verifications;
    mapping(address => bool) public minted;

    constructor(
        IERC20 _verifierToken,
        bytes32 _context,
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) {
        verifierToken = _verifierToken;
        context = _context;
    }

    /**
     * @dev Set context
     * @param _context BrightID context used for verifying users
     */
    function setContext(bytes32 _context) external onlyOwner {
        context = _context;
        emit ContextSet(_context);
    }

    /**
     * @dev Set verifier token
     * @param _verifierToken ERC20 standard verifier token contract address
     */
    function setVerifierToken(IERC20 _verifierToken) external onlyOwner {
        verifierToken = _verifierToken;
        emit VerifierTokenSet(_verifierToken);
    }

    /**
     * @dev Register a user by BrightID verification
     * @param addrs The history of addresses used by this user in the app
     * @param timestamp The BrightID node's verification timestamp
     * @param v Component of signature
     * @param r Component of signature
     * @param s Component of signature
     */
    function register(
        address[] memory addrs,
        uint256 timestamp,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(
            verifications[addrs[0]].time < timestamp,
            "Newer verification registered before"
        );

        bytes32 message = keccak256(
            abi.encodePacked(context, addrs, timestamp)
        );
        address signer = ecrecover(message, v, r, s);
        require(
            verifierToken.balanceOf(signer) > 0,
            "Signer is not authorized"
        );

        for (uint256 i = 0; i < addrs.length; i++) {
            verifications[addrs[i]].time = timestamp;
            verifications[addrs[i]].addrs = addrs;
        }
    }

    /**
     * @dev Check an address is verified or not
     * @param addr The contextid used for verifying users
     */
    function isVerified(address addr) public view returns (bool) {
        return verifications[addr].time > 0;
    }

    /**
     * @dev Mint to address (`to`) if such an address is already verified and haven't minted before
     * @param to The address to mint to
     */
    function mint(address to) external {
        require(isVerified(to), "Address is not verified");
        require(!minted[to], "Address already minted");
        _mint(to, _tokenIdTracker.current());
        _tokenIdTracker.increment();
    }

    /**
     * @dev See {ERC721-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);
        bool same = false;
        for (uint i = 0; i < verifications[from].addrs.length; i++) {
            if (verifications[from].addrs[i] == to) {
                same = true;
                break;
            }
        }
        require(same, "Not linked to the same BrightID");
    }
}
