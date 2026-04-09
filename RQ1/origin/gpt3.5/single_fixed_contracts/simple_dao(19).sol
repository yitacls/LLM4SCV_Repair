/*
 * @source: http://blockchain.unica.it/projects/ethereum-survey/attacks.html#simpledao
 * @author: -
 * @vulnerable_at_lines: 19
 */

pragma solidity ^0.4.2;

contract SimpleDAO {
  mapping (address => uint) public credit;

  function donate(address to) payable {
    credit[to] += msg.value;
  }

  function withdraw(uint amount) { 
    if (credit[msg.sender] >= amount && amount > 0) { 
        uint256 toWithdraw = credit[msg.sender]; 
        credit[msg.sender] = 0; 
        if (!(msg.sender.call.value(toWithdraw)())) { 
            revert(); 
        } 
    } 
}

  function queryCredit(address to) returns (uint){
    return credit[to];
  }
}
