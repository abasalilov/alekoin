const assert = require("assert");
const AleKoin = artifacts.require("AleKoin");

let alekoin;

contract("AleKoin", accounts => {
  let owner = accounts[0];
  let contributor1 = accounts[1];
  let contributor2 = accounts[2];
  let contributor3 = accounts[3];
  let contributor4 = accounts[4];
  let contributor5 = accounts[5];

  beforeEach(async () => {
    alekoin = await AleKoin.new();
  });

  it("sets an owner", async () => {
    assert.equal(await alekoin.owner.call(), owner);
  });

  it("sets original creator set as admin", async function() {
    const isAdmin = await alekoin.hasRole(owner, "admin");
    assert.strictEqual(isAdmin, true);
  });

  it("adds original creator to whitelist", async function() {
    const isInWhitelist = await alekoin.whitelist(owner);
    assert.strictEqual(isInWhitelist, true);
  });

  it("sets name to AleKoin", async () => {
    let name = await alekoin.name.call();
    assert.strictEqual(name, "AleKoin");
  });

  it("sets initial total balance set by AleKoin", async () => {
    const alekoinSupply = await alekoin.totalSupply.call();
    const amount = alekoinSupply["c"][0];
    assert.equal(amount, 1000000000000);
  });

  it("should [approve] token transaction", async () => {
    let tokenWei = 50000000;
    let originalAllowance = await alekoin.allowance(owner, contributor1);
    await alekoin.approve(contributor1, tokenWei);
    let resultAllowance = await alekoin.allowance(owner, contributor1);
    assert.strictEqual(originalAllowance.toNumber(), 0);
    assert.strictEqual(resultAllowance.toNumber(), 50000000);
  });

  it("should be active initially", async function() {
    assert.strictEqual(await getStatus(alekoin), true);
  });

  it("should [approve]", async function() {
    await alekoin.deactivate();
    const currentStatus = await getStatus(alekoin);
    assert.strictEqual(currentStatus, false);
  });

  it("should [transfer]", async function() {
    const trxAmt = 80000000000000000000000000;
    await makeTransfer(alekoin, trxAmt, contributor1, owner);
    const contributor1Bal = await alekoin.balanceOf(contributor1);
    const ownerTotal = await alekoin.balanceOf(owner);
    assert.strictEqual(contributor1Bal.toNumber(), trxAmt);
    assert.strictEqual(ownerTotal.toNumber(), 20000000000000000000000000);
  });

  it("should [deactivate]", async function() {
    await alekoin.deactivate();
    const currentStatus = await getStatus(alekoin);
    assert.strictEqual(currentStatus, false);
  });

  it("should [reactivate]", async function() {
    await alekoin.deactivate();
    await alekoin.reactivate();
    const currentStatus = await getStatus(alekoin);
    assert.strictEqual(currentStatus, true);
  });

  it("should [addToWhitelist]", async function() {
    await alekoin.addToWhiteList(contributor1);
    const isWhitelisted = await alekoin.whitelist(contributor1);
    assert.strictEqual(isWhitelisted, true);
  });

  it("should [removeFromWhitelist]", async function() {
    await alekoin.addToWhiteList(contributor1);
    let isWhitelisted = await alekoin.whitelist(contributor1);
    assert.strictEqual(isWhitelisted, true);
    await alekoin.removeFromWhiteList(contributor1);
    isWhitelisted = await alekoin.whitelist(contributor1);
    assert.strictEqual(isWhitelisted, false);
  });

  // is this a reasonable test?
  it("should be able to [approve] whitelisted user trx after [deactivate]", async function() {
    await alekoin.deactivate();
    let tokenWei = 50000000;
    await alekoin.approve(contributor3, tokenWei);
    let resultAllowance = await alekoin.allowance(owner, contributor3);
    assert.strictEqual(resultAllowance.toNumber(), 50000000);
  });

  it("should be able to [countTransactions]", async function() {
    await alekoin.updateBulkTransferAccount(contributor5);
    await makeTransfer(
      alekoin,
      50000000000000000000000000,
      contributor1,
      owner
    );
    await makeTransfer(
      alekoin,
      20000000000000000000000000,
      contributor1,
      owner
    );
    await makeTransfer(
      alekoin,
      10000000000000000000000000,
      contributor1,
      owner
    );
    const newOwnerTotal = await alekoin.balanceOf(contributor1);
    const trxs = await alekoin.countTransactions.call();
    assert.strictEqual(trxs.toNumber(), 3);
  });
});

// helpers

async function getStatus(coin) {
  const status = await coin.active.call();
  return status;
}

async function makeTransfer(coin, amt, address, owner) {
  let tokenWei = amt ? amt : 50000000;
  let contributor = address ? address : contributor4;
  await alekoin.approve(contributor, tokenWei);
  let resultAllowance = await alekoin.allowance(owner, contributor);
  await alekoin.transfer(contributor, tokenWei);
}
