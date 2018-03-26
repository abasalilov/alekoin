const assert = require("assert");
const ganache = require("ganache-cli");
const Web3 = require("web3");
const provider = ganache.provider();
const web3 = new Web3(provider);

const { interface, bytecode } = require("../compile");

let testAccts;
let AleKoin;
let owner;

beforeEach(async () => {
  // get list of all accts
  testAccts = await web3.eth.getAccounts();
  // use account to deploy token

  AleKoin = await new web3.eth.Contract(JSON.parse(interface))
    .deploy({
      data: bytecode,
      arguments: []
    })
    .send({ from: testAccts[0], gas: "1000000" });

  AleKoin.setProvider(provider);

  owner = testAccts[1];
});

it("deploys token", () => {
  assert.ok(AleKoin.options.address);
});

it("has initial total balance set by AleKoin", async () => {
  const amount = await AleKoin.methods.totalSupply().call();
  assert.equal(amount, 1000000);
});

it("should pass if contract is deployed", async () => {
  let name = await AleKoin.methods.name().call();
  assert.strictEqual(name, "AleKoin");
});

it("should return inital token wei balance of 1*10^27", async function() {
  let ownerBalance = await AleKoin.methods.balanceOf(owner).call();
  ownerBalance = ownerBalance.toString();
  assert.strictEqual(ownerBalance, "1000000");
});

// it("should properly return the [totalSupply] of tokens", async function() {
//   let totalSupply = await AleKoin.totalSupply.call();
//   totalSupply = totalSupply.toString();
//   assert.strictEqual(totalSupply, "1e+27");
// });

it("should [approve] token for [transferFrom]", async function() {
  let approver = owner;
  let spender = testAccts[3];
  let originalAllowance = await AleKoin.methods
    .allowance(approver, spender)
    .call();
  let tokenWei = 5000000;
  await AleKoin.methods.approve(spender, tokenWei).call();
  let resultAllowance = await AleKoin.methods
    .allowance(approver, spender)
    .call();
  console.log("resultAllowance", resultAllowance, typeof resultAllowance);
  assert.strictEqual(Number(originalAllowance), 0);
});

// it("should fail to [transferFrom] more than allowed", async function() {
//   let from = owner;
//   let to = web3.eth.accounts[2];
//   let spenderPrivateKey = privateKeys[2];
//   let tokenWei = 10000000;
//   let allowance = await AleKoin.allowance.call(from, to);
//   let ownerBalance = await AleKoin.balanceOf.call(from);
//   let spenderBalance = await AleKoin.balanceOf.call(to);
//   data = web3Contract.transferFrom.getData(from, to, tokenWei);
//   let errorMessage;
//   try {
//     await rawTransaction(to, spenderPrivateKey, AleKoin.address, data, 0);
//   } catch (error) {
//     errorMessage = error.message;
//   }
//   assert.strictEqual(
//     errorMessage,
//     "VM Exception while processing transaction: invalid opcode"
//   );

// });
// it("should [transferFrom] approved tokens", async function() {
//   let from = owner;
//   let to = web3.eth.accounts[2];
//   let spenderPrivateKey = privateKeys[2];
//   let tokenWei = 5000000;
//   let allowance = await AleKoin.allowance.call(from, to);
//   let ownerBalance = await AleKoin.balanceOf.call(from);
//   let spenderBalance = await AleKoin.balanceOf.call(to);
//   data = web3Contract.transferFrom.getData(from, to, tokenWei);
//   let result = await rawTransaction(
//     to,
//     spenderPrivateKey,
//     AleKoin.address,
//     data,
//     0
//   );
//   let allowanceAfter = await AleKoin.allowance.call(from, to);
//   let ownerBalanceAfter = await AleKoin.balanceOf.call(from);
//   let spenderBalanceAfter = await AleKoin.balanceOf.call(to);
//   // Correct account balances
//   // toString() numbers that are too large for js
//   assert.strictEqual(
//     ownerBalance.toString(),
//     ownerBalanceAfter.add(tokenWei).toString()
//   );
//   assert.strictEqual(
//     spenderBalance.add(tokenWei).toString(),
//     spenderBalanceAfter.toString()
//   );
//   // Proper original allowance
//   assert.strictEqual(allowance.toNumber(), tokenWei);
//   // All of the allowance should have been used
//   assert.strictEqual(allowanceAfter.toNumber(), 0);
//   // Normal transaction hash, not an error.
//   assert.strictEqual(0, result.indexOf("0x"));
// });
