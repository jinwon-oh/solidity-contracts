const EventNFT = artifacts.require("EventNFT");

module.exports = async function (_deployer, network, accounts) {
  console.log("network:", network);
  console.log("accounts:", accounts);
  // Use deployer to state migration tasks.
  await _deployer.deploy(
    EventNFT,
    "TEST NFT",
    "TNFT",
    accounts[0],
    "https://sample.url/"
  );
};
