
pragma solidity ^0.4.22;

import "./ERC223ReceivingContract.sol";
import "./ShapeCoin.sol";

contract GMASCrowdSale is ERC223ReceivingContract, Whitelist {

    using SafeMath for uint;

    ShapeCoin private _token;

    uint private _price;
    uint private _limit;
    uint private _available;
    bool public active;

    mapping (address => uint) private _limits;

    event Buy(address beneficiary, uint amount);
    event PauseSale(uint amount);

    modifier isActive() {
        require(active == true);
        _;
    }

    modifier isShapeCoin() {
        require(msg.sender == address(_token));
        _;
    }

    modifier valid(address to, uint amount) {
        assert(amount > 0);
        amount = amount.div(_price);
        assert(_limit >= amount);
        assert(_limit >= _limits[to].add(amount));
        _;
    }

    constructor(address token, uint price, uint limit) public {
        _token = ShapeCoin(token);
        _price = price;
        _limit = limit;
    }

    function () public payable {
        // Not enough gas for the transaction so prevent users from sending ether
        revert();
    }

    function buy() public payable {
        return buyFor(msg.sender);
    }

    function buyFor(address beneficiary) public isActive() valid(beneficiary, msg.value) payable {
        uint amount = msg.value.div(_price);
        _token.transfer(beneficiary, amount);
        _available = _available.sub(amount);
        _limits[beneficiary] = _limits[beneficiary].add(amount);
        emit Buy(beneficiary, amount);
    }

    function tokenFallback(address, uint _value, bytes)
        isShapeCoin
        public {
        _available = _available.add(_value);
    }

    function availableBalance() view public returns (uint) {
        return _available;
    }

    function pauseSale() onlyOwner public {
        active = false;
    }

    function upgradeToken(address upgradedToken) onlyOwner public {
        _token = ShapeCoin(upgradedToken);
    }
}




