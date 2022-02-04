const ERC721Soulbound = artifacts.require("ERC721Soulbound");

module.exports = function (deployer) {
  deployer.deploy(ERC721Soulbound);
};
