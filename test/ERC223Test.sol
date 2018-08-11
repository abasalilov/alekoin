pragma solidity ^0.4.22;

import "truffle/Assert.sol";
import "../contracts/ERC223.sol";
import "truffle/DeployedAddresses.sol";
import "./helpers/ContractReceiverOverrider.sol";
import "./helpers/ContractReceiver.sol";

// Contract that isn't working with ERC223 tokens
contract ContractNonReceiver {
}

// Proxy contract for testing throws
// contract ThrowProxy {
//   address public target;
//   bytes data;
//   constructor(address _target) {
//     target = _target;
//   }

//   //prime the data using the fallback function.
//   function() {
//     data = msg.data;
//   }

//   function tokenFallback(address _from, uint _value, bytes _data) {
//   }

//   function execute() returns (bool) {
//     return target.call(data);
//   }
// }


contract ERC223Test {
  uint public initialBalance = 10 ether;
  string tokenName = "LED Token";
  string tokenSymbol = "LED";
  event Show (string addy);

  ContractReceiver receiver = new ContractReceiver();
  uint expected = 10000000000000000;
  // bytes memory empty;

function testSettingAnOwnerDuringCreation() public {
    ERC223 erc223 = new ERC223();
    Assert.equal(erc223.balanceOf(tx.origin), 10000000000000000000, "An owner is different than a deployer");
  }

// function testSettingAnOwnerOfDeployedContract() public {
//     // setting an owner of deployed contract, instead of new
//     ERC223 erc223 = ERC223(DeployedAddresses.ERC223());
//     Assert.equal(erc223.owner(), msg.sender, "An owner is different than a deployer");
//   }

// function testSettingATokenNameOfContract() public {
//     // setting an owner of deployed contract, instead of new
//     ERC223 erc223 = ERC223(DeployedAddresses.ERC223());
//     Assert.equal(erc223.name(), tokenName, "The token name is different than expected");
//   }


// function testSettingASymbolOfContract() public {
//     // setting an owner of deployed contract, instead of new
//     ERC223 erc223 = ERC223(DeployedAddresses.ERC223());
//     Assert.equal(erc223.symbol(), tokenSymbol, "The token symbol is different than expected");
//   }

// function testSettingATotalSupply() public {
//     // setting an owner of deployed contract, instead of new
//     ERC223 erc223 = ERC223(DeployedAddresses.ERC223());
//     Assert.equal(erc223.totalSupply(), 10000000000000000000, "The token total supply is different than 100000000000 * 10**8;");
//   }

// function testInitialTransferToOwner() public {
//     ERC223 erc223 = ERC223(DeployedAddresses.ERC223());
//     Assert.equal(erc223.balanceOf(msg.sender), 10000000000000000000, "Initial token amount transfer to owner is different than 0");
//   }

function testInitialTransferToPurchaser() public {
    // ERC223 erc223 = new ERC223();
    ERC223 erc223 = ERC223(DeployedAddresses.ERC223());
    emit Show("THE");
    // erc223.transfer(msg.sender, 100)
    // Assert.equal(erc223.balanceOf(msg.sender), 100, "Transfer of 1000 tokens to `this` address and balance not confirmed");
  }
    
}