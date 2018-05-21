pragma solidity ^0.4.19;

import "../../contracts/AleKoin.sol";
import "truffle/DeployedAddresses.sol";
import "truffle/Assert.sol";

contract AleKoinTest {
    uint public initialBalance = 10 ether;
    address public target;

    AleKoin alekoin;
    function () public payable {}

    function beforeEach() public {
        alekoin = new AleKoin();
    }


    address testAddress = DeployedAddresses.AleKoin();
    uint amt1 = 10000000000000000000000000;
    uint256[] amounts = [amt1];

    function testSettingAnOwnerOfDeployedContract() public {
        alekoin = AleKoin(DeployedAddresses.AleKoin());
        Assert.equal(alekoin.owner(), msg.sender, "An owner is different than a deployer");
    }

    function testInitialBalance() public {
        Assert.equal(alekoin.totalSupply(), 100000000000000000000000000, 
        "Initial total supply amount is different than 1 billion to 18 decimal places");
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

    function testAddWhiteList() public {
        alekoin.addToWhiteList(testAddress);
        Assert.equal(alekoin.confirmWhiteListStatus(testAddress), true, "Should whitelist address");
    }

    function testRemoveFromWhiteList() public {
        alekoin.addToWhiteList(0x6C19dc8D03cB7a93d3451E40De418Be6B03e9226);
        alekoin.removeFromWhiteList(0x6C19dc8D03cB7a93d3451E40De418Be6B03e9226);
        Assert.equal(alekoin.confirmWhiteListStatus(0x6C19dc8D03cB7a93d3451E40De418Be6B03e9226), false, "Should remove address from whitelist");
    }

  // refactor test, too expensive 
  // function testBulkTranser() public {
  //   address acct2 = 0x6C19dc8D03cB7a93d3451E40De418Be6B03e9226;
  //   address acct3 = 0xDF65B54810b9074786112fE29427Ad18f656D8eB;
  //   address[] memory spenders = [acct3];
  //   address[] memory receivers = [acct2];
  //   address acct1 = 0x1aC00a7EbfF157Ba63A30397A47beC9851081cE5;
  //   address acct4 = 0xA3060571ea657d64Ce70B01E9346E94dB3e59cEF;
  //   receivers.push(acct1);
  //   spenders.push(acct4);
  //   amounts.push(amt1);
  //   alekoin.bulkTransfer(spenders,receivers, amounts);
  //   Assert.equal(alekoin.balanceOf(0xDF65B54810b9074786112fE29427Ad18f656D8eB), 10000000000000000000000000, "Should remove address from whitelist");
  // }

}
