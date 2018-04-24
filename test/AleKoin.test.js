const assert = require("assert");
const AleKoin = artifacts.require("AleKoin");

let alekoin;

contract("AleKoin", accounts => {
  let owner = accounts[0];
  let contributor1 = accounts[1];
  let contributor2 = accounts[2];

  beforeEach(async () => {
    // get list of all accts
    alekoin = await AleKoin.new();
  });

  it("sets an owner", async () => {
    assert.equal(await alekoin.owner.call(), owner);
  });

  it("has name set to AleKoin", async () => {
    let name = await alekoin.name.call();
    assert.strictEqual(name, "AleKoin");
  });

  it("has initial total balance set by AleKoin", async () => {
    const alekoinSupply = await alekoin.totalSupply.call();
    const amount = alekoinSupply["c"][0];
    assert.equal(amount, 1000000000000);
  });

  it("should [approve] token for [transferFrom]", async () => {
    const initBalance = web3.eth.getBalance(owner);
    let tokenWei = 50000000;
    let originalAllowance = await alekoin.allowance(owner, contributor1);
    await alekoin.approve(contributor1, tokenWei);
    let resultAllowance = await alekoin.allowance(owner, contributor1);
    assert.strictEqual(originalAllowance.toNumber(), 0);
    assert.strictEqual(resultAllowance.toNumber(), 50000000);
  });

  it("should have original creator set as admin", async function() {
    const currentAdmin = await alekoin.admin.call();
    assert.strictEqual(currentAdmin, owner);
  });

  it("should [updateAdmin] for token", async function() {
    await alekoin.updateAdmin(contributor1);
    const updatedAdmin = await alekoin.admin.call();
    assert.strictEqual(updatedAdmin, contributor1);
  });
});
