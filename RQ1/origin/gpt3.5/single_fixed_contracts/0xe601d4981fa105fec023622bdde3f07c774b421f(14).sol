pragma solidity ^0.4.25;
contract Token {
    address public issuer;
    mapping (address => uint) public balances;
    function Token() {
        issuer = tx.origin;
        balances[issuer] = 10000000;
    }
    function transfer(address _to, uint _amount) public {
                require(balances[msg.sender] >= _amount, 'Insufficient balance');
                balances[msg.sender] -= _amount;
                balances[_to] += _amount;
            }
}