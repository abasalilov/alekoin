require("babel-register");
require("babel-polyfill");

module.exports = {
  copyPackages: ["zeppelin-solidity"],
  skipFiles: ["Migrations.sol"],
  port: 8555,
  testrpcOptions: "-p 8555"
  // norpc: true
};
