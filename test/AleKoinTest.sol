// contracts/FundingTest.sol
pragma solidity ^0.4.19;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/AleKoin.sol";

contract AleKoinTest {
  uint public initialBalance = 10 ether;
  address public target;

  AleKoin alekoin;
  function () public payable {}

  function beforeEach() public {
    alekoin = new AleKoin();
  }

  // address[] bulkTransferSenders = [address[0]]
  address testAddress = DeployedAddresses.AleKoin();
  address[] spenders;
  address[] receivers;
  uint amt1 = 10000000000000000000000000;
  address acct1 = 0x1aC00a7EbfF157Ba63A30397A47beC9851081cE5;
  address acct2 = 0x6C19dc8D03cB7a93d3451E40De418Be6B03e9226;
  address acct3 = 0xDF65B54810b9074786112fE29427Ad18f656D8eB;
  address acct4 = 0xA3060571ea657d64Ce70B01E9346E94dB3e59cEF;
  uint256[] amounts = [amt1];

  event Log(address _address);

  function testSettingAnOwnerOfDeployedContract() public {
    alekoin = AleKoin(DeployedAddresses.AleKoin());
    Assert.equal(alekoin.owner(), msg.sender, "An owner is different than a deployer");
  }

  function testInitialBalance() public {
    Assert.equal(alekoin.totalSupply(), 100000000000000000000000000, "Initial total supply amount is different than 1 billion to 18 decimal places");
  }

  function testSettingAnOwnerDuringCreation() public {
    Assert.equal(alekoin.owner(), this, "An owner is different than a deployer");
  }

  function testInitialStatusAndDeactivation() public {
    Assert.equal(alekoin.active(), true, "Initial status of contract is active");
    alekoin.deactivate();
    Assert.equal(alekoin.active(), false, "Status after deactivation should be false");
    alekoin.reactivate();
    Assert.equal(alekoin.active(), true, "Status after reactivation of contract should be active");
  }

  function testInitialNotWhiteListed() public {
    Assert.equal(alekoin.whitelist(target), false, "Random address should not be on whitelist");
  }

  function testUpdatedWallet() public {
    alekoin.updateFundsWallet(target);
    Assert.equal(alekoin.fundsWallet(), target, "fundsWallet address should be updated");
  }

  event Show(address[] _a);

  function testAddWhiteList() public {
    alekoin.addToWhiteList(testAddress);
    Assert.equal(alekoin.confirmWhiteListStatus(testAddress), true, "Should whitelist address");
  }

  function testRemoveFromWhiteList() public {
    alekoin.addToWhiteList(0x6C19dc8D03cB7a93d3451E40De418Be6B03e9226);
    alekoin.removeFromWhiteList(0x6C19dc8D03cB7a93d3451E40De418Be6B03e9226);
    Assert.equal(alekoin.confirmWhiteListStatus(0x6C19dc8D03cB7a93d3451E40De418Be6B03e9226), false, "Should remove address from whitelist");
  }

  function testBulkTranser() public {
    receivers.push(acct1);
    receivers.push(acct2);
    spenders.push(acct3);
    spenders.push(acct4);
    amounts.push(amt1);
    alekoin.bulkTransfer(spenders,receivers, amounts);
    Assert.equal(alekoin.balanceOf(0xDF65B54810b9074786112fE29427Ad18f656D8eB), 10000000000000000000000000, "Should remove address from whitelist");
  }

}
// 0x627306090abab3a6e1400e9345bc60c78a8bef57
// 0x345ca3e014aaf5dca488057592ee47305d9b3e10

//  ["0x1ac00a7ebff157ba63a30397a47bec9851081ce5",
//        "0x6c19dc8d03cb7a93d3451e40de418be6b03e9226",
//        "0x40a6f8832b405eeab658d026de2a5a0a9aac490c",
//        "0xdf65b54810b9074786112fe29427ad18f656d8eb",
//        "0xa3060571ea657d64ce70b01e9346e94db3e59cef",
//        "0x58a51cd6030c8e275f862a471578ea79cca5b6c8",
//        "0x1a415152b6a66a4b647950cbf9ffd5aba1e2f104",
//        "0xba600a4b61b8bb811c2860b66f80976d9b8e0efb",
//        "0xa50aabb763952026764dcb280e9ce98dc9d757c9",
//        "0x163f2925f9ddbab0c675f28c2eef3c7d47528968"];