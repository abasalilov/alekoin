// contracts/FundingTest.sol
pragma solidity ^0.4.19;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/AleKoin.sol";

contract AleKoinTest {
  AleKoin alekoin;
  function () public payable {}

  function beforeEach() public {
    alekoin = new AleKoin();
  }

  // function testInitialBalance() public {
  //   Assert.equal(alekoin.totalSupply(), 100000000000000000000000000, "Initial total supply amount is different than 1 billion to 18 decimal places");
  // }

  // function testSettingAnOwnerOfDeployedContract() public {
  //   alekoin = AleKoin(DeployedAddresses.AleKoin());
  //   Assert.equal(alekoin.owner(), msg.sender, "An owner is different than a deployer");
  // }
}
