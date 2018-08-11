pragma solidity ^0.4.22;

import "truffle/Assert.sol";
import "../contracts/ERC223.sol";
import "truffle/DeployedAddresses.sol";
import "./helpers/ContractReceiverOverrider.sol";
// import "./helpers/ContractReceiver.sol";

// Contract that isn't working with ERC223 tokens
contract ContractNonReceiver {}

// Proxy contract for testing throws
contract ThrowProxy {
  address public target;
  bytes data;
  constructor(address _target) {
    target = _target;
  }

  //prime the data using the fallback function.
  function() {
    data = msg.data;
  }

  function tokenFallback(address _from, uint _value, bytes _data) {
  }

  function execute() returns (bool) {
    return target.call(data);
  }
}


contract ERC223Test {
  uint public initialBalance = 10 ether;
  string tokenName = "LED Token";
  string tokenSymbol = "LED";
  event Show (string addy);

  function testSettingAnOwnerDuringCreation() public {
      ERC223 erc223 = new ERC223();
      Assert.equal(erc223.balanceOf(address(this)), 10000000000000000000, "An owner is different than a deployer");
    }

  function testSettingAnOwnerOfDeployedContract() public {
      // setting an owner of deployed contract, instead of new
      ERC223 erc223 = ERC223(DeployedAddresses.ERC223());
      Assert.equal(erc223.owner(), msg.sender, "An owner is different than a deployer");
    }

  function testSettingATokenNameOfContract() public {
      // setting an owner of deployed contract, instead of new
      ERC223 erc223 = ERC223(DeployedAddresses.ERC223());
      Assert.equal(erc223.name(), tokenName, "The token name is different than expected");
    }


  function testSettingASymbolOfContract() public {
      // setting an owner of deployed contract, instead of new
      ERC223 erc223 = ERC223(DeployedAddresses.ERC223());
      Assert.equal(erc223.symbol(), tokenSymbol, "The token symbol is different than expected");
    }

  function testSettingATotalSupply() public {
      uint expected = 10000000000000000000;
      // setting an owner of deployed contract, instead of new
      ERC223 erc223 = ERC223(DeployedAddresses.ERC223());
      Assert.equal(erc223.totalSupply(), expected, "The token total supply is different than 100000000000 * 10**8;");
    }

  function testInitialTransferToOwner() public {
      uint expected = 10000000000000000000;
      ERC223 erc223 = ERC223(DeployedAddresses.ERC223());
      Assert.equal(erc223.balanceOf(msg.sender), expected, "Initial token amount transfer to owner is different than 0");
    }

  // function testTraspasingWithDataToInvalidContract() {
  //     ERC223 token = new ERC223();
  //     ContractNonReceiver nonReceiver = new ContractNonReceiver();

  //     ThrowProxy throwProxy = new ThrowProxy(address(token));

  //     uint expected = 10000000000000000000;
  //     bytes memory empty;

      // Assert.equal(token.balanceOf(address(this)), expected, "Owner should have 1000 LED Coin initially");
      /* Proxy Contract will execute and catch the throw so it needs the balance */
      // Assert.isTrue(token.transfer(address(throwProxy), 1000), 'Transfer to Proxy success');
      // ERC223(address(throwProxy)).transfer(address(nonReceiver), 50, empty);
      // bool r = throwProxy.execute.gas(2000)();
      // Assert.isFalse(r, "Should be false, as it should throw");
      // Assert.equal(token.balanceOf(address(throwProxy)), 100, "Owner should have 50 LED Coin initially");
      // Assert.equal(token.balanceOf(address(nonReceiver)), 0, "Owner should have 50 LED Coin initially");
    // }

  // function testTraspasingWithoutDataToValidContract() {
  //   ERC223 token = new ERC223();

  //   ContractReceiver receiver = new ContractReceiver();
  //   uint expected = 10000000000000000;

  //   Assert.equal(token.balanceOf(address(this)), expected, "Owner should have 10000000000000000 MetaCoin initially");
  //   Assert.isTrue(token.transfer(address(receiver), 5000000000000000), 'Transfer success');
  //   Assert.equal(token.balanceOf(address(this)), 5000000000000000, "Owner should have 5000000000000000 MetaCoin initially");
  //   Assert.equal(token.balanceOf(address(receiver)), 5000000000000000, "Owner should have 5000000000000000 MetaCoin initially");
  // }
    
}