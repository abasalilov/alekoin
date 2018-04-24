// migrations/2_alekoin.js
const Alekoin = artifacts.require("./AleKoin.sol");

module.exports = function(deployer) {
  deployer.deploy(Alekoin);
};
