const assert = require("assert");
const AleKoin = artifacts.require("AleKoin");

let alekoin;

contract("AleKoin", accounts => {
  let owner = accounts[0];
  let walletAddress = accounts[1];
  let contributor1 = accounts[2];
  let contributor2 = accounts[3];
  let contributor3 = accounts[4];
  let contributor4 = accounts[5];
  let contributor5 = accounts[6];
  let contributor6 = accounts[7];

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
    const isInWhitelist = await alekoin.confirmWhiteListStatus.call(owner);
    assert.strictEqual(isInWhitelist, true);
  });

  it("sets name to AleKoin", async () => {
    let name = await alekoin.name.call();
    assert.strictEqual(name, "AleKoin");
  });

  it("sets initial total balance set by AleKoin", async () => {
    const alekoinSupply = await alekoin.totalSupply.call();
    const amount = alekoinSupply.toNumber();
    assert.equal(amount, 100000000000000000000000000);
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
    const isWhitelisted = await alekoin.confirmWhiteListStatus.call(
      contributor1
    );
    assert.strictEqual(isWhitelisted, true);
  });

  it("should [removeFromWhitelist]", async function() {
    await alekoin.addToWhiteList(contributor1);
    let isWhitelisted = await alekoin.confirmWhiteListStatus.call(contributor1);
    assert.strictEqual(isWhitelisted, true);
    await alekoin.removeFromWhiteList(contributor1);
    isWhitelisted = await alekoin.confirmWhiteListStatus.call(contributor1);
    assert.strictEqual(isWhitelisted, false);
  });

  it("should be able to [approve] whitelisted user trx after [deactivate]", async function() {
    await alekoin.deactivate();
    let tokenWei = 50000000;
    await alekoin.approve(contributor3, tokenWei);
    let resultAllowance = await alekoin.allowance(owner, contributor3);
    assert.strictEqual(resultAllowance.toNumber(), 50000000);
  });

  it("should be able to [countTransactions]", async function() {
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
    const trxs = await alekoin.countTransactions.call();
    assert.strictEqual(trxs.toNumber(), 3);
  });

  it("should be able to [getTransactionAccts]", async function() {
    await makeTransfer(
      alekoin,
      50000000000000000000000000,
      contributor1,
      owner
    );
    await makeTransfer(
      alekoin,
      20000000000000000000000000,
      contributor2,
      owner
    );
    await makeTransfer(
      alekoin,
      10000000000000000000000000,
      contributor3,
      owner
    );
    const trxAccts = await alekoin.getTransactionAccts.call();
    assert.strictEqual(trxAccts.length, 3);
    assert.strictEqual(trxAccts[0], contributor1);
    assert.strictEqual(trxAccts[1], contributor2);
    assert.strictEqual(trxAccts[2], contributor3);
  });

  it("should be able to [getTransaction]", async function() {
    const contributor1Amount = 50000000000000000000000000;
    const contributor2Amount = 20000000000000000000000000;
    await makeTransfer(alekoin, contributor1Amount, contributor1, owner);
    await makeTransfer(alekoin, contributor2Amount, contributor2, owner);
    const trx0 = await alekoin.getTransaction(contributor1);
    const trx1 = await alekoin.getTransaction(contributor2);
    const amt1 = trx0[1].toNumber();
    const amt2 = trx1[1].toNumber();
    assert.strictEqual(amt1, contributor1Amount);
    assert.strictEqual(amt2, contributor2Amount);
  });

  it("should be able to [updateFundsWallet]", async function() {
    await alekoin.updateFundsWallet(contributor5);
    const updatedWallet = await alekoin.fundsWallet.call();
    assert.strictEqual(updatedWallet, contributor5);
  });

  it("should be able to [_bulkTransfer]", async function() {
    const amt1 = 10000000000000000000000000;
    const amt2 = 20000000000000000000000000;
    const amt3 = 30000000000000000000000000;
    const senders = [contributor1, contributor2, contributor3];
    const receivers = [contributor4, contributor5, contributor6];
    const amounts = [amt1, amt2, amt3];

    await alekoin.bulkTransfer(senders, receivers, amounts);
    const received1 = await alekoin.balanceOf(contributor1);
    const received2 = await alekoin.balanceOf(contributor2);
    const received3 = await alekoin.balanceOf(contributor3);

    assert.strictEqual(received1.toNumber(), amt1);
    assert.strictEqual(received2.toNumber(), amt2);
    assert.strictEqual(received3.toNumber(), amt3);
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
  await alekoin.allowance(owner, contributor);
  await alekoin.transfer(contributor, tokenWei);
}
