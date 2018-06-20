// migrations/2_alekoin.js
const ShapeCoin = artifacts.require("./ShapeCoin.sol");

module.exports = function(deployer) {
  deployer.deploy(ShapeCoin);
};
