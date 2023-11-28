const EventNFT = artifacts.require("EventNFT");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("EventNFT", function (accounts) {
  it("should assert true", async function () {
    await EventNFT.deployed();
    return assert.isTrue(true);
  });

  it("show info", async function () {
    const ins = await EventNFT.deployed();
    console.log(await ins.name());
    console.log(await ins.symbol());
    console.log(await ins.owner());
    return assert.isTrue(true);
  });

  it("set cost", async function () {
    const ins = await EventNFT.deployed();
    const result = await ins.setCost("1000000000000000000");
    console.log(result);
    return assert.isTrue(true);
  });

  it("mint 1", async function () {
    const ins = await EventNFT.deployed();
    const result = await ins.mint({
      from: accounts[2],
      value: "1000000000000000000",
    });
    console.log(result);
    return assert.isTrue(true);
  });

  it("mint 2", async function () {
    const ins = await EventNFT.deployed();
    const result = await ins.mint({
      from: accounts[2],
      value: "1000000000000000000",
    });
    console.log(result);
    return assert.isTrue(true);
  });

  it("mint 3", async function () {
    const ins = await EventNFT.deployed();
    const result = await ins.mint({
      from: accounts[2],
      value: "1000000000000000000",
    });
    console.log(result);
    return assert.isTrue(true);
  });

  it("mint 4", async function () {
    const ins = await EventNFT.deployed();
    const result = await ins.mint({
      from: accounts[2],
      value: "1000000000000000000",
    });
    console.log(result);
    return assert.isTrue(true);
  });

  it("mint 5", async function () {
    const ins = await EventNFT.deployed();
    const result = await ins.mint({
      from: accounts[2],
      value: "1000000000000000000",
    });
    console.log(result);
    return assert.isTrue(true);
  });

  it("mint 6", async function () {
    const ins = await EventNFT.deployed();
    const result = await ins.mint({
      from: accounts[2],
      value: "1000000000000000000",
    });
    console.log(result);
    return assert.isTrue(true);
  });

  it("mint 7", async function () {
    const ins = await EventNFT.deployed();
    const result = await ins.mint({
      from: accounts[2],
      value: "1000000000000000000",
    });
    console.log(result.logs[0].args);
    return assert.isTrue(true);
  });

  it("transfer", async function () {
    const ins = await EventNFT.deployed();
    const result = await ins.transferFrom(accounts[2], accounts[1], 1);
    console.log(result.logs[0].args);
    return assert.isTrue(true);
  });

  it("set approval for all", async function () {
    const ins = await EventNFT.deployed();
    const result = await ins.setApprovalForAll(accounts[0], true, {
      from: accounts[2],
    });
    console.log(result);
    return assert.isTrue(true);
  });

  it("claim", async function () {
    const ins = await EventNFT.deployed();
    const result = await ins.claim(accounts[2], [1, 2, 3, 4, 5, 6, 7]);
    console.log(result.logs);
    return assert.isTrue(true);
  });
});
