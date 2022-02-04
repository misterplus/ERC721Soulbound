## ERC721Soulbound
A proof of concept inspired by Vitalik Buterin's article titled [Soulbound](https://vitalik.eth.limo/general/2022/01/26/soulbound.html) and a forum post by Triplespeeder titled [Implementing Soulbound NFTs with BrightID](https://forum.brightid.org/t/implementing-soulbound-nfts-with-brightid/430).


Note that this is only a PROOF OF CONCEPT, security issues not related to BrightID and it's verification system are not taken into consideration.

## Features
- Uses BrightID to verify unique humans.
- Only verified addresses can mint tokens.
- Only addresses associated with the same BrightID can transfer tokens from / to each other.
- In the event of a wallet getting compromised, the BrightID controller can transfer tokens on behalf of the victim wallet, so long as the transfer transaction is submitted by an address associated with the same BrightID as the stolen one.