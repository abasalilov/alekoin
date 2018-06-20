// pragma solidity ^0.4.19;

// import "../../contracts/ShapeCoin.sol";
// import "truffle/DeployedAddresses.sol";
// import "truffle/Assert.sol";

// contract ShapeCoinTest {
//     uint public initialBalance = 10 ether;
//     address public target;

//     ShapeCoin shapecoin;
//     function () public payable {}

//     function beforeEach() public {
//         shapecoin = new ShapeCoin();
//     }


//     address testAddress = DeployedAddresses.ShapeCoin();
//     uint amt1 = 10000000000000000000000000;
//     uint256[] amounts = [amt1];

//     function testSettingAnOwnerOfDeployedContract() public {
//         shapecoin = ShapeCoin(DeployedAddresses.ShapeCoin());
//         Assert.equal(testAddress, msg.sender, "An owner is different than a deployer");
//     }

//     function testInitialBalance() public {
//         Assert.equal(shapecoin.totalSupply(), 100000000000000000000000000, 
//         "Initial total supply amount is different than 1 billion to 18 decimal places");
//     }

//     function testSettingAnOwnerDuringCreation() public {
//         Assert.equal(testAddress, this, "An owner is different than a deployer");
//     }

// }