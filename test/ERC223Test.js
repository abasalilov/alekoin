const ERC223 = artifacts.require("ERC223");

contract("ERC223", accounts => {
  const [firstAccount, purchaser1] = accounts;

  it("sets an owner", async () => {
    const erc223 = await ERC223.new();

    assert.equal(await erc223.owner.call(), firstAccount);
  });

  // it("sets an token name", async () => {
  //   const erc223 = await ERC223.new();

  //   assert.equal(await erc223.name.call(), "LED Token");
  // });

  // it("sets an token symbol", async () => {
  //   const erc223 = await ERC223.new();

  //   assert.equal(await erc223.symbol.call(), "LED");
  // });

  // it("sets a total supply", async () => {
  //   const erc223 = await ERC223.new();
  //   const supplyBN = await erc223.totalSupply.call();
  //   assert.equal(await supplyBN.toNumber(), 10000000000000000000);
  // });

  // it("intially transfers entire supply to owner", async () => {
  //   const erc223 = await ERC223.new();
  //   const initialOwnerSupply = await erc223.balanceOf(firstAccount);
  //   assert.equal(await initialOwnerSupply.toNumber(), 10000000000000000000);
  // });

  // it("transfers tokens to purchaser #1", async () => {
  // const erc223 = await ERC223.new();
  // await erc223.transfer(purchaser1, 10);
  // const purchaser1Supply = await erc223.balanceOf(purchaser1);
  // assert.equal(await purchaser1Supply.toNumber(), 10);
  // });
});
