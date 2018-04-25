pragma solidity ^0.4.22;
import "zeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import 'zeppelin-solidity/contracts/ownership/Whitelist.sol';
import 'zeppelin-solidity/contracts/ownership/rbac/RBAC.sol';

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

    struct TransactionData {
        address trxAddress;
        uint256 amount;
    }

    event MadeTrx(address _addy);
    event MadeStep(uint _step);
    
    mapping (address => TransactionData) transactionsMap;
    address[] public transactionAccts;

   function setTransaction(address _address, uint _value) public {
        TransactionData transactionInstance = transactionsMap[_address];

        transactionInstance.trxAddress = _address;
        transactionInstance.amount = _value;
        
        transactionAccts.push(_address) -1;
        emit MadeTrx(_address);
        
    }

    function getTransactionAccts() view public returns (address[]) {
        return transactionAccts;
    }

    function getTransaction(address trx) view public returns (address, uint256) {
        return (transactionsMap[trx].trxAddress, transactionsMap[trx].amount);
    }

    function getTransactionAmout(address trx) view public returns (uint256) {
        return transactionsMap[trx].amount;
    }

    function countTransactions() view public returns (uint) {
        return transactionAccts.length;
    }
  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    setTransaction(_to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;
  
  event BulkTransfer(uint);
  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    setTransaction(_to, _value);
    emit MadeTrx(_to);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract AleKoin is StandardToken, Whitelist, RBAC { 

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
        bulkTransferAcct = msg.sender;
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

    struct tuple {
        address trxAddress;
        uint amount;
    }

    function bulkTransfer () managerOnly public {
        uint length = countTransactions();
        uint total = 0;
        address[] memory transactionsList= getTransactionAccts(); 
        
            for(uint i=0;i<length;i++){
                emit MadeStep(i);
                address bulkTransferFromAddress = transactionsList[i];
                uint bulkTransferAmount = getTransactionAmout(transactionsList[i]);
                total +=bulkTransferAmount;
                approve(bulkTransferFromAddress, bulkTransferAmount);
                // allowance(owner, bulkTransferFromAddress);
                // transfer(bulkTransferFromAddress, bulkTransferAmount); 
            }

            emit MadeStep(total);
            // total is here


        // for (uint i = 0; i < length; i++) {
        //     address bulkTransferFromAddress = transactionsList[i];
        //       approve(bulkTransferFromAddress, bulkTransferAmount);
        //       allowance(owner, bulkTransferFromAddress);
        //       transfer(bulkTransferFromAddress, bulkTransferAmount); 
        // }
    }

    function updateBulkTransferAccount(address newBulkAcct) public managerOnly {
        addToWhiteList(newBulkAcct);
        bulkTransferAcct = newBulkAcct;
    }

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