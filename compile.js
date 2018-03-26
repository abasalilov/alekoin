const path = require("path");
const fs = require("fs");
const solc = require("solc");

const aleKoinPath = path.resolve(__dirname, "contracts", "AleKoin.sol");

console.log("aleKoinPath", aleKoinPath);
const source = fs.readFileSync(aleKoinPath, "utf8");

module.exports = solc.compile(source, 1).contracts[":AleKoin"];
