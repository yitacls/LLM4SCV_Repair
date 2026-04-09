/*
 * @source: https://ericrafaloff.com/analyzing-the-erc20-short-address-attack/
 * @author: -
 * @vulnerable_at_lines: 18
 */

 pragma solidity ^0.4.11;

 contract MyToken {
     mapping (address => uint) balances;

     event Transfer(address indexed _from, address indexed _to, uint256 _value);

     function MyToken() {
         balances[tx.origin] = 10000;
     }
     // <yes> <report> SHORT_ADDRESSES
     function sendCoin(address to, uint256 amount) public returns (bool sufficient) {
    require(to != address(0), "Invalid address: zero address");
    require(amount > 0, "Amount must be greater than zero");
    require(balances[msg.sender] >= amount, "Insufficient balance");
    
    balances[msg.sender] = balances[msg.sender].sub(amount);
    balances[to] = balances[to].add(amount);
    
    Transfer(msg.sender, to, amount);
    
    // Return value check to validate the transfer completed successfully
    require(balances[msg.sender] < balances[msg.sender].add(amount), "Transfer validation failed");
    
    return true;
}

     function getBalance(address addr) constant returns(uint) {
         return balances[addr];
     }
 }
