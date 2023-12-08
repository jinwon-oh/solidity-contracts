const EventNFT = artifacts.require("EventNFT");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("EventNFT", function (accounts) {
  const minted = [];
  const owned = [];
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
    assert.isTrue(result.receipt.status);
  });

  it("mint 1", async function () {
    const ins = await EventNFT.deployed();
    const result = await ins.mintTo(accounts[2], 1, {
      from: accounts[2],
      value: "1000000000000000000",
    });
    assert.isTrue(result.receipt.status);
    minted.push(result.logs[0].args.tokenId);
    owned.push(result.logs[0].args.tokenId);
  });

  it("mint 2", async function () {
    const ins = await EventNFT.deployed();
    const result = await ins.mintTo(accounts[2], 1, {
      from: accounts[2],
      value: "1000000000000000000",
    });
    assert.isTrue(result.receipt.status);
    minted.push(result.logs[0].args.tokenId);
    owned.push(result.logs[0].args.tokenId);
  });

  it("mint 3", async function () {
    const ins = await EventNFT.deployed();
    const result = await ins.mintTo(accounts[2], 1, {
      from: accounts[2],
      value: "1000000000000000000",
    });
    assert.isTrue(result.receipt.status);
    minted.push(result.logs[0].args.tokenId);
    owned.push(result.logs[0].args.tokenId);
  });

  it("mint 4", async function () {
    const ins = await EventNFT.deployed();
    const result = await ins.mintTo(accounts[2], 1, {
      from: accounts[2],
      value: "1000000000000000000",
    });
    assert.isTrue(result.receipt.status);
    minted.push(result.logs[0].args.tokenId);
    owned.push(result.logs[0].args.tokenId);
  });

  it("mint 5", async function () {
    const ins = await EventNFT.deployed();
    const result = await ins.mintTo(accounts[2], 1, {
      from: accounts[2],
      value: "1000000000000000000",
    });
    assert.isTrue(result.receipt.status);
    minted.push(result.logs[0].args.tokenId);
    owned.push(result.logs[0].args.tokenId);
  });

  it("mint 6", async function () {
    const ins = await EventNFT.deployed();
    const result = await ins.mintTo(accounts[2], 1, {
      from: accounts[2],
      value: "1000000000000000000",
    });
    assert.isTrue(result.receipt.status);
    minted.push(result.logs[0].args.tokenId);
    owned.push(result.logs[0].args.tokenId);
  });

  it("mint 7", async function () {
    const ins = await EventNFT.deployed();
    const result = await ins.mintTo(accounts[1], 1, {
      from: accounts[1],
      value: "1000000000000000000",
    });
    assert.isTrue(result.receipt.status);
    minted.push(result.logs[0].args.tokenId);
  });

  it("mint 8", async function () {
    const ins = await EventNFT.deployed();
    const result = await ins.mintTo(accounts[2], 1, {
      from: accounts[2],
      value: "1000000000000000000",
    });
    assert.isTrue(result.receipt.status);
    minted.push(result.logs[0].args.tokenId);
    owned.push(result.logs[0].args.tokenId);
  });

  // it("transfer", async function () {
  //   const ins = await EventNFT.deployed();
  //   const result = await ins.transferFrom(accounts[1], accounts[2], 7, {
  //     from: accounts[1],
  //   });
  //   assert.isTrue(result.receipt.status);
  // });

  it("check before claim", async function () {
    const ins = await EventNFT.deployed();
    const total = await ins.totalSupply();
    const balance = await ins.balanceOf(accounts[2]);
    assert.isTrue(
      total.toNumber() === minted.length && balance.toNumber() === owned.length
    );
  });

  // it("set approval for all", async function () {
  //   const ins = await EventNFT.deployed();
  //   const result = await ins.setApprovalForAll(accounts[0], true, {
  //     from: accounts[2],
  //   });
  //   assert.isTrue(result.receipt.status);
  // });

  it("invalid claim", async function () {
    const ins = await EventNFT.deployed();
    const result = await ins.claim(minted.slice(0, 7));
    assert.isTrue(!result.receipt.status);
  });

  it("claim", async function () {
    const ins = await EventNFT.deployed();
    const result = await ins.claim(owned, {
      from: accounts[2],
    });
    assert.isTrue(result.receipt.status);
  });

  it("check after claim", async function () {
    const ins = await EventNFT.deployed();
    const total = await ins.totalSupply();
    const balance = await ins.balanceOf(accounts[2]);
    assert.isTrue(total.toNumber() === 1 && balance.toNumber() === 0);
  });
});
