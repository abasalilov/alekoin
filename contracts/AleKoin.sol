pragma solidity ^0.4.22;

import "./Ownable.sol";

 contract Token is Ownable {

    function totalSupply() constant public returns (uint256 supply) {}

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant public returns (uint256 balance) {
        return balance;
    }

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success) {}

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success) {}

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StandardToken is Token {

    function transfer(address _to, uint256 _value) public returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else {return false;}
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else {return false;}
    }

    function balanceOf(address _owner) constant public returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;
}

contract AleKoin is StandardToken { 

    /* Public variables of the token */

    struct Transaction {
        address _spender;
        uint _amount;
        address _owner;
        uint _balanceAfterTrx;
    }

    struct Whitelist {
        address _whitelistAddress;
        bool trxSent;
    }


    Transaction[] public transactions;
    Whitelist[] public whitelist;
    string public name;                   
    string public symbol;     
    string public version = "H1.1"; 
    uint8 public constant DECIMALS = 18;
    uint256 public constant INITIAL_SUPPLY = 100000000 * (10 ** uint256(DECIMALS));
    uint256 public deployed;
    uint256 public lastUpdated;
    uint256 public unitsOneEthCanBuy;     
    uint256 public totalEthInWei;      
    uint256 public currentSupply;      
    address public fundsWallet;
    address public admin;
    address public bulkTransferAcct;
    bool public active;

    modifier isActive() {
        require(active == true);
        _;
    }

    modifier isNotActive() {
        require(active == false);
        _;
    }
    

    function AleKoin() public {
        balances[msg.sender] = 0;               
        totalSupply = INITIAL_SUPPLY;   
        currentSupply = INITIAL_SUPPLY;                     
        name = "AleKoin";                                   
        symbol = "ALEKS";
        deployed = now;
        lastUpdated = now;                                             
        unitsOneEthCanBuy = 1000;                                     
        fundsWallet = msg.sender;
        admin = msg.sender;    
        active = true;                                
    }

    function() payable public isActive {
        totalEthInWei = totalEthInWei + msg.value;
        uint256 amount = msg.value * unitsOneEthCanBuy;
        require(balances[fundsWallet] >= amount);
        balances[fundsWallet] = balances[fundsWallet] - amount;
        balances[msg.sender] = balances[msg.sender] + amount;
        Transfer(fundsWallet, msg.sender, amount); 
        currentSupply = balances[owner] - amount;
        _updateTrxHx(msg.sender, amount, currentSupply);
        fundsWallet.transfer(msg.value);                               
    }

    function updateAdmin(address newAdmin) public onlyOwner {
        admin = newAdmin;
    }

    function updateBulkTransferAccount(address newBulkAcct) public onlyOwner {
        bulkTransferAcct = newBulkAcct;
    }

    function _commenceBulkTransfer() private onlyOwner isNotActive {
        uint length = transactions.length;

        for (uint i = 0; i<length; i++) {
            transfer(bulkTransferAcct, transactions[i]._amount); 
        }

    }

    function _updateTrxHx(address _spender, uint256 _trxValue, uint _balanceAfterTrx) private isActive {
        transactions.push(Transaction(_spender, _trxValue, fundsWallet, totalSupply));
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public isActive returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }

    function updateWhitelist(address _newWhitelistAddress) isActive {
        whitelist.push(Whitelist(_newWhitelistAddress, false));
    }

    function deactivateSale() private onlyOwner {
        active = false;
    }
}