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
  assert.strictEqual(Number(originalAllowance), 0);
});
