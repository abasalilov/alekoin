pragma solidity ^0.4.22;

contract FoundationToken {
    string internal _symbol;
    string internal _name;
    uint8 internal _decimals;
    uint internal _totalSupply = 1000;
    mapping (address => uint) internal _balanceOf;
    mapping (address => mapping (address => uint)) internal _allowances;
    
    constructor(string symbol, string name, uint8 decimals, uint totalSupply) public {
        _symbol = symbol;
        _name = name;
        _decimals = decimals;
        _totalSupply = totalSupply;
    }
    
    function name() public view returns (string) {
        return _name;
    }
    
    function symbol() public view returns (string) {
        return _symbol;
    }
    
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    
    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }
    
    function balanceOf(address _addr) public view returns (uint);

    // @notice send `_value` token to `_to` from `msg.sender`
    // @param _to The address of the recipient
    // @param _value The amount of token to be transferred
    // @return Whether the transfer was successful or not
    function transfer(address _to, uint _value) public returns (bool);
    event Transfer(address indexed _from, address indexed _to, uint _value);
}