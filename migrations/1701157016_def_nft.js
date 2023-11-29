const DefNFT = artifacts.require("DefNFT");

module.exports = async function (_deployer, network, accounts) {
  console.log("network:", network);
  console.log("accounts:", accounts);
  // Use deployer to state migration tasks.
  await _deployer.deploy(
    DefNFT,
    "Default NFT",
    "DNFT",
    "https://exmple.io/",
    "https://example.io/unrevealed/",
    "0x0000000000000000000000000000000000000000"
  );
};
