pragma solidity ^0.4.11;
contract XG4K {
    address public coiner;
    mapping (address => uint) public balances;
    event Issue(address from, address to, uint amount);
    function XG4K() public {
        coiner = msg.sender;
        balances[msg.sender] = 100000;
    }
    function mint(address receiver, uint amount) public {
    require(msg.sender == coiner);
    balances[receiver] = balances[receiver].add(amount);
}
    function send(address receiver, uint amount) public {
        if (balances[msg.sender] < amount) return;
        balances[msg.sender] -= amount;
        balances[receiver] += amount;  
        Issue(msg.sender, receiver, amount);
    }
}
