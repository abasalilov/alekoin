pragma solidity ^0.4.22;

import 'zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';
import 'zeppelin-solidity/contracts/ownership/Whitelist.sol';
import 'zeppelin-solidity/contracts/ownership/rbac/RBAC.sol';

contract AleKoin is  StandardToken, Whitelist, RBAC { 

    modifier managerOnly() {
        require(hasRole(msg.sender, "admin") == true || whitelist[msg.sender] == true);
        _;
    }

    modifier isActive(){
        require(active == true);
        _;
    }

    modifier isAllowed(){
        require(active == true || hasRole(msg.sender, "admin") == true || whitelist[msg.sender] == true);
        _;
    }

    modifier bulkTransferReady(){
        require(bulkTransferAcct != owner);
        _;
    }

    event Deactivate();

    event Reactivate();

    struct TransactionData {
        address trxAddress;
        uint256 amount;
    }
    
    mapping (address => TransactionData) transactionsMap;
    address[] public transactionAccts;

   function setTransaction(address _address, uint _value) public {
        TransactionData transactionInstance = transactionsMap[_address];

        transactionInstance.trxAddress = _address;
        transactionInstance.amount = _value;
        
        transactionAccts.push(_address) -1;

    }

    function getTransactionAccts() view public returns (address[]) {
        return transactionAccts;
    }

    function getTransaction(address trx) view public returns (address, uint256) {
        return (transactionsMap[trx].trxAddress, transactionsMap[trx].amount);
    }

    function countTransactions() view public returns (uint) {
        return transactionAccts.length;
    }

    /* Public variables of the token */
    string public name;                   
    uint8 public decimals;                
    string public symbol;                 
    string public version = "H1.0"; 
    uint256 public unitsOneEthCanBuy;     
    uint256 public totalEthInWei;         
    address public fundsWallet;   
    uint256 public totalSupply;
    uint256 public trxLength;
    uint256 public constant INITIAL_SUPPLY = 100000000000000000000000000;   
    bool public active = false;    
    address public bulkTransferAcct;


    function AleKoin() public {
        balances[msg.sender] = INITIAL_SUPPLY;           
        totalSupply = INITIAL_SUPPLY;                        
        name = "AleKoin";                                   
        decimals = 18;                                               
        symbol = "ALKS";                  
        trxLength = 0;                           
        unitsOneEthCanBuy = 1000;                                     
        fundsWallet = msg.sender;  
        active = true;        
        whitelist[msg.sender] = true;   
    }

    function() payable public isAllowed {
        totalEthInWei = totalEthInWei + msg.value;
        uint256 amount = msg.value * unitsOneEthCanBuy;
        require(balances[fundsWallet] >= amount);
        balances[fundsWallet] = balances[fundsWallet] - amount;
        balances[msg.sender] = balances[msg.sender] + amount;
        emit Transfer(fundsWallet, msg.sender, amount); 
        setTransaction(msg.sender, amount);
        fundsWallet.transfer(msg.value);   
    }

    function addToWhiteList(address newManagerAddress) managerOnly public isActive returns (bool) {
        if (!whitelist[newManagerAddress]) {
            whitelist[newManagerAddress] = true;
            emit WhitelistedAddressAdded(newManagerAddress);
            return true;
         }
        return false;
    }

    function removeFromWhiteList(address managerAddress) managerOnly public isActive returns (bool) {
        if (whitelist[managerAddress]) {
            whitelist[managerAddress] = false;
            emit WhitelistedAddressRemoved(managerAddress);
            return true;
        }
        return false; 
    }

    // function _bulkTransfer () managerOnly private {
    //     uint length = transactionsList.length;

    //     for (uint i = 0; i < length; i++) {
    //           approve(bulkTransferAcct, transactionsList[i]._amount);
    //           allowance(owner, bulkTransferAcct);
    //           transfer(bulkTransferAcct, transactionsList[i]._amount); 
    //     }
    // }

    function updateBulkTransferAccount(address newBulkAcct) public managerOnly {
        addToWhiteList(newBulkAcct);
        bulkTransferAcct = newBulkAcct;
    }

    // function commenceBulkTransfer() public managerOnly {
    //     _bulkTransfer();
    // }

    function deactivate() managerOnly public {
        active = false;
        emit Deactivate();
    }

    function reactivate() managerOnly public {
        active = true;
        emit Reactivate();
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public isActive returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

        if (!_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) {revert();}
        return true;
    }
}