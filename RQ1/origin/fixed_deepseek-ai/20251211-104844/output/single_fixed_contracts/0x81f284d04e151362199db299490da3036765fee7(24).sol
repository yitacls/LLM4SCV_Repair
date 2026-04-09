pragma solidity ^0.4.11;
contract QatarCoin{
    uint public constant _totalsupply = 95000000;
    string public constant symbol = "QTA";
    string public constant name = "Qatar Coin";
    uint8 public constant decimls = 18;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    function QatarCoin() {
       balances[msg.sender] = _totalsupply;
    }
    function totalSupply() constant returns (uint256 totalSupply) {
        return _totalsupply;
    }
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
    function transfer(address _to, uint256 _value) public returns (bool success) {
    require(_to != address(0), "Cannot transfer to zero address");
    require(balances[msg.sender] >= _value, "Insufficient balance");
    require(_value > 0, "Transfer value must be positive");
    
    // Safe subtraction using require (SafeMath pattern for Solidity 0.4.x)
    require(balances[msg.sender] >= _value);
    balances[msg.sender] = balances[msg.sender] - _value;
    
    // Safe addition using require (SafeMath pattern for Solidity 0.4.x)
    uint256 newBalance = balances[_to] + _value;
    require(newBalance >= balances[_to], "Overflow detected");
    balances[_to] = newBalance;
    
    Transfer(msg.sender, _to, _value);
    return true;
}
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        require(
            allowed[_from][msg.sender] >= _value
            && balances[_from] >= _value
            && _value > 0 
            );
            balances[_from] -= _value;
            balances[_to] += _value;  
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
    }
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}