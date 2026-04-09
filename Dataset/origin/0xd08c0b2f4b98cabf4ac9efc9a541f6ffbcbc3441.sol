pragma solidity ^0.4.25;
contract Coin {
    address public minter;
    mapping (address => uint) public balances;
    event Sent(address from, address to, uint amount);
    function Coin() {
        minter = msg.sender;
        balances[msg.sender]=1000;
    }
    function mint(address receiver, uint amount) {
        if (msg.sender != minter) return;
        balances[receiver] += amount;  // fault line
    }
    function send(address receiver, uint amount) {
        if (balances[msg.sender] < amount) return;
        if (balances[receiver]+ amount < balances[receiver]) return;  
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        Sent(msg.sender, receiver, amount);
    }
}