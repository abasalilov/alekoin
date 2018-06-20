const ShapeCoin = artifacts.require("ShapeCoin");
const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";

const assertRevert = async promise => {
  try {
    await promise;
    assert.fail("Expected revert not received");
  } catch (error) {
    const revertFound = error.message.search("revert") >= 0;
    assert(revertFound, `Expected "revert", got ${error} instead`);
  }
};

contract("ShapeCoin", accounts => {
  let token;
  const creator = accounts[0];
  const recipient = accounts[1];
  const anotherAccount = accounts[2];
  const newOwner = accounts[3];
  const recipient2 = accounts[4];

  beforeEach(async function() {
    token = await ShapeCoin.new({ from: creator });
  });

  it("has a name", async function() {
    const name = await token.name();
    assert.equal(name, "ShapeCoin");
  });

  it("has a symbol", async function() {
    const symbol = await token.symbol();
    assert.equal(symbol, "SHPC");
  });

  it("has 18 decimals", async function() {
    const decimals = await token.decimals();
    assert(decimals.eq(18));
  });

  it("assigns the initial total supply to the creator", async function() {
    const totalSupply = await token.totalSupply();
    const creatorBalance = await token.balanceOf(creator);
    assert(creatorBalance.eq(totalSupply));
  });

  describe("when the requested account has no tokens", function() {
    it("returns zero", async function() {
      const balance = await token.balanceOf(anotherAccount);
      assert.equal(balance, 0);
    });
  });

  describe("when the requested account has some tokens", function() {
    it("returns the total amount of tokens", async function() {
      const start = await token.balanceOf(newOwner);
      await token.transfer(newOwner, 100);
      const balance = await token.balanceOf(newOwner);
      assert.equal(balance, 100);
    });
  });

  describe("transfer", function() {
    describe("when the sender does not have enough balance", function() {
      const moreThanCreated = 1000001000;
      const to = recipient;

      it("reverts", async function() {
        await token.transfer(to, moreThanCreated);
        const newOwnerBalance = await token.balanceOf(newOwner);
        const creatorBalance = await token.balanceOf(creator);
        const totalSupply = await token.totalSupply();

        assert.equal(newOwnerBalance.toNumber(), 0);
        assert.equal(creatorBalance.toNumber(), totalSupply);
      });

      describe("when the sender has enough balance", function() {
        const amount = 1000000000;

        it("transfers the requested amount", async function() {
          const acct6 = accounts[5];
          const acct7 = accounts[6];
          await token.transfer(acct6, amount);

          const senderBalance = await token.balanceOf(creator);

          const acct7Balance = await token.balanceOf(acct7);

          const acct6Balance = await token.balanceOf(acct6);

          assert.equal(senderBalance.toNumber(), 0);
          assert.equal(acct7Balance.toNumber(), 0);
          assert.equal(acct6Balance.toNumber(), amount);

          // test double transfer
          await token.transfer(acct7, amount, { from: acct6 });
          const acct7Balance2 = await token.balanceOf(acct7);
          const acct6Balance2 = await token.balanceOf(acct6);
          assert.equal(acct7Balance2.toNumber(), amount);
          assert.equal(acct6Balance2.toNumber(), 0);
        });

        it("emits a transfer event", async function() {
          const { logs } = await token.transfer(recipient, amount, {
            from: creator
          });

          assert.equal(logs.length, 1);
          assert.equal(logs[0].event, "Transfer");
          assert.equal(logs[0].args._from, creator);
          assert.equal(logs[0].args._to, recipient);
          assert(logs[0].args._value.eq(amount));
        });
      });
    });
  });
});
