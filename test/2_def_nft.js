const DefNFT = artifacts.require("DefNFT");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("DefNFT", function (accounts) {
  it("should assert true", async function () {
    await DefNFT.deployed();
    return assert.isTrue(true);
  });

  it("show info", async function () {
    const ins = await DefNFT.deployed();
    console.log(await ins.name());
    console.log(await ins.symbol());
    console.log(await ins.owner());
    return assert.isTrue(true);
  });
});
