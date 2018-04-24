const path = require("path");
const fs = require("fs");
const solc = require("solc");

const aleKoinPath = path.resolve(__dirname, "contracts", "AleKoin.sol");

const ERC20 = path.resolve(
  __dirname,
  "node_modules/zeppelin-solidity/contracts/token/ERC20",
  "ERC20.sol"
);

const ERC20Basic = path.resolve(
  __dirname,
  "node_modules/zeppelin-solidity/contracts/token/ERC20",
  "ERC20Basic.sol"
);

const Whitelist = path.resolve(
  __dirname,
  "node_modules/zeppelin-solidity/contracts/ownership",
  "Whitelist.sol"
);

const Ownable = path.resolve(
  __dirname,
  "node_modules/zeppelin-solidity/contracts/ownership",
  "Ownable.sol"
);

var input = {
  "AleKoin.sol": fs.readFileSync(aleKoinPath, "utf8"),
  "ERC20.sol": fs.readFileSync(ERC20, "utf8"),
  "ERC20Basic.sol": fs.readFileSync(ERC20Basic, "utf8"),
  "Ownable.sol": fs.readFileSync(Ownable, "utf8"),
  "Whitelist.sol": fs.readFileSync(Whitelist, "utf8")
};

module.exports = solc.compile({ sources: input }, 1);
