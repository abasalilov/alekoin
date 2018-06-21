pragma solidity ^0.4.22;

import "./FoundationToken.sol";
import "./ERC20.sol";
import "./ERC223.sol";
import "./ERC223ReceivingContract.sol";
import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract ShapeCoin is FoundationToken("SHPC", "ShapeCoin", 18), ERC20, ERC223 {

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
            emit Transfer(msg.sender, _to, _value);
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
            emit Transfer(msg.sender, _to, _value, _data);
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
            emit Transfer(_from, _to, _value);
            return true;
        }
        return false;
    }

    function approve(address _spender, uint _value) public returns (bool) {
        _allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint) {
        return _allowances[_owner][_spender];
    }
}


/**
 * @title Roles
 * @author Francisco Giordano (@frangio)
 * @dev Library for managing addresses assigned to a Role.
 * See RBAC.sol for example usage.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
    * @dev give an address access to this role
    */
    function add(Role storage role, address addr)
        internal
    {
        role.bearer[addr] = true;
    }

    /**
    * @dev remove an address' access to this role
    */
    function remove(Role storage role, address addr)
        internal
    {
        role.bearer[addr] = false;
    }

    /**
    * @dev check if an address has this role
    * // reverts
    */
    function check(Role storage role, address addr)
        view
        internal
    {
        require(has(role, addr));
    }

    /**
    * @dev check if an address has this role
    * @return bool
    */
    function has(Role storage role, address addr)
        view
        internal
        returns (bool)
    {
        return role.bearer[addr];
    }
}

/**
 * @title RBAC (Role-Based Access Control)
 * @author Matt Condon (@Shrugs)
 * @dev Stores and provides setters and getters for roles and addresses.
 * Supports unlimited numbers of roles and addresses.
 * See //contracts/mocks/RBACMock.sol for an example of usage.
 * This RBAC method uses strings to key roles. It may be beneficial
 * for you to write your own implementation of this interface using Enums or similar.
 * It's also recommended that you define constants in the contract, like ROLE_ADMIN below,
 * to avoid typos.
 */
contract RBAC {
    using Roles for Roles.Role;

    mapping (string => Roles.Role) private roles;

    event RoleAdded(address indexed operator, string role);
    event RoleRemoved(address indexed operator, string role);

    /**
    * @dev reverts if addr does not have role
    * @param _operator address
    * @param _role the name of the role
    * // reverts
    */
    function checkRole(address _operator, string _role)
        view
        public
    {
        roles[_role].check(_operator);
    }

    /**
    * @dev determine if addr has role
    * @param _operator address
    * @param _role the name of the role
    * @return bool
    */
    function hasRole(address _operator, string _role)
        view
        public
        returns (bool)
    {
        return roles[_role].has(_operator);
    }

    /**
    * @dev add a role to an address
    * @param _operator address
    * @param _role the name of the role
    */
    function addRole(address _operator, string _role)
        internal
    {
        roles[_role].add(_operator);
        emit RoleAdded(_operator, _role);
    }

    /**
    * @dev remove a role from an address
    * @param _operator address
    * @param _role the name of the role
    */
    function removeRole(address _operator, string _role)
        internal
    {
        roles[_role].remove(_operator);
        emit RoleRemoved(_operator, _role);
    }

    /**
    * @dev modifier to scope access to a single role (uses msg.sender as addr)
    * @param _role the name of the role
    * // reverts
    */
    modifier onlyRole(string _role)
    {
        checkRole(msg.sender, _role);
        _;
    }

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor() public {
        owner = msg.sender;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
    * @dev Allows the current owner to relinquish control of the contract.
    * @notice Renouncing to ownership will leave the contract without an owner.
    * It will not be possible to call the functions with the `onlyOwner`
    * modifier anymore.
    */
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

    /**
    * @dev Transfers control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

/**
 * @title Whitelist
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.
 * This simplifies the implementation of "user permissions".
 */

contract Whitelist is Ownable, RBAC {
    string public constant ROLE_WHITELISTED = "whitelist";

    /**
    * @dev Throws if operator is not whitelisted.
    * @param _operator address
    */
    modifier onlyIfWhitelisted(address _operator) {
        checkRole(_operator, ROLE_WHITELISTED);
        _;
    }

    /**
    * @dev add an address to the whitelist
    * @param _operator address
    * @return true if the address was added to the whitelist, false if the address was already in the whitelist
    */
    function addAddressToWhitelist(address _operator) onlyOwner
        public
    {
        addRole(_operator, ROLE_WHITELISTED);
    }

    /**
    * @dev getter to determine if address is in whitelist
    */
    function whitelist(address _operator)
        public
        view
        returns (bool)
    {
        return hasRole(_operator, ROLE_WHITELISTED);
    }

    /**
    * @dev add addresses to the whitelist
    * @param _operators addresses
    * @return true if at least one address was added to the whitelist,
    * false if all addresses were already in the whitelist
    */

    function addAddressesToWhitelist(address[] _operators) onlyOwner public {
        for(uint256 i = 0 ; i < _operators.length; i++){
            addAddressToWhitelist(_operators[i]);
            /* solium-disable */
        }
            /* solium-enable */
    }

    /**
    * @dev remove an address from the whitelist
    * @param _operator address
    * @return true if the address was removed from the whitelist,
    * false if the address wasn't in the whitelist in the first place
    */
    function removeAddressFromWhitelist(address _operator)
        onlyOwner
        public
    {
        removeRole(_operator, ROLE_WHITELISTED);
    }

    /**
    * @dev remove addresses from the whitelist
    * @param _operators addresses
    * @return true if at least one address was removed from the whitelist,
    * false if all addresses weren't in the whitelist in the first place
    */
    function removeAddressesFromWhitelist(address[] _operators) onlyOwner public {
        for (uint256 i = 0; i < _operators.length; i++) {
            removeAddressFromWhitelist(_operators[i]);
        }
    }
}
