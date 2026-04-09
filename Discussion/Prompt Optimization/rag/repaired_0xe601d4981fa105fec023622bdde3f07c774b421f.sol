pragma solidity ^0.4.25;

contract Token {
    address public issuer;
    mapping (address => uint) public balances;

    function Token() {
        issuer = msg.sender;
        balances[issuer] = 10000000;
    }

    function transfer(address _to, uint _amount) {
        require(tx.origin == issuer); // Access control check
        if (balances[msg.sender] < _amount) {
            revert();
        }
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
    }
}