pragma solidity ^0.4.22;

import "./Token.sol";
import "./ERC20.sol";
import "./ERC223.sol";
import "./ERC223ReceivingContract.sol";
import "https://www.github.com/OpenZeppelin/zeppelin-solidity/contracts/math/SafeMath.sol";

contract ShapeCoin is Token("SHPC", "ShapeCoin", 18, 1000000000), ERC20, ERC223 {

    using SafeMath for uint;

    constructor() public {
        _balanceOf[msg.sender] = _totalSupply;
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address _addr) public view returns (uint) {
        return _balanceOf[_addr];
    }

    /**
     *  ** FOR ADDRESSES **
     *
     * @dev Transfer the specified amount of tokens to the specified address.
     *      This function works the same with the previous one
     *      but doesn't contain `_data` param.
     *      Added due to backwards compatibility reasons.
     *
     *  @param _to    Receiver address.
     *  @param _value Amount of tokens that will be transferred.
     *  @return Whether the transfer was successful or not
     */

    function transfer(address _to, uint _value) public returns (bool) {
        if (_value > 0 && _value <= _balanceOf[msg.sender] && !isContract(_to)) {
            _balanceOf[msg.sender] = _balanceOf[msg.sender].sub(_value);
            _balanceOf[_to] = _balanceOf[_to].add(_value);
            Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }


    /**
     *  ** FOR CONTRACTS **
     *
     *  @dev Transfer the specified amount of tokens to the specified address.
     *      Invokes the `tokenFallback` function if the recipient is a contract.
     *      The token transfer fails if the recipient is a contract
     *      but does not implement the `tokenFallback` function
     *      or the fallback function to receive funds.
     *
     *  @notice send `_value` token to `_to` from `msg.sender`
     *  @param _to The address of the recipient
     *  @param _value The amount of token to be transferred
     *  @param _data The data to be passed to our contract that we are actually going to allow to have data passed to
     *  @return Whether the transfer was successful or not
     */
    
    function transfer(address _to, uint _value, bytes _data) public returns (bool) {
        if (_value > 0 && _value <= _balanceOf[msg.sender] && isContract(_to)) {
            _balanceOf[msg.sender] = _balanceOf[msg.sender].sub(_value);
            _balanceOf[_to] = _balanceOf[_to].add(_value);
            ERC223ReceivingContract _contract = ERC223ReceivingContract(_to);
            _contract.tokenFallback(msg.sender, _value, _data);
            Transfer(msg.sender, _to, _value, _data);
            return true;
        }
        return false;
    }

    function isContract(address _addr) private view returns (bool) {
        uint codeSize;
        /* solium-disable */
        assembly {
            codeSize := extcodesize(_addr)
        }
        /* solium-enable */
        return codeSize > 0;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        if (_allowances[_from][msg.sender] > 0 &&
            _value > 0 &&
            _allowances[_from][msg.sender] >= _value &&
            _balanceOf[_from] >= _value) {
            _balanceOf[_from] = _balanceOf[_from].sub(_value);
            _balanceOf[_to] = _balanceOf[_to].add(_value);
            _allowances[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        }
        return false;
    }

    function approve(address _spender, uint _value) public returns (bool) {
        _allowances[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint) {
        return _allowances[_owner][_spender];
    }
}
