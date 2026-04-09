/*
 * @source: https://github.com/sigp/solidity-security-blog
 * @author: -
 * @vulnerable_at_lines: 22
 */

//added pragma version
 pragma solidity ^0.4.0;
 
 contract TimeLock {

     mapping(address => uint) public balances;
     mapping(address => uint) public lockTime;

     function deposit() public payable {
         balances[msg.sender] += msg.value;
         lockTime[msg.sender] = now + 1 weeks;
     }

     function increaseLockTime(uint _secondsToIncrease) public {
    require(_secondsToIncrease > 0, "Increase amount must be greater than 0");
    lockTime[msg.sender] = lockTime[msg.sender].add(_secondsToIncrease);
}

     function withdraw() public {
         require(balances[msg.sender] > 0);
         require(now > lockTime[msg.sender]);
         uint transferValue = balances[msg.sender];
         balances[msg.sender] = 0;
         msg.sender.transfer(transferValue);
     }
 }
