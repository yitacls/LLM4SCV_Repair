/*
 * @source: https://github.com/sigp/solidity-security-blog
 * @author: Suhabe Bugrara
 * @vulnerable_at_lines: 20,27
 */

 pragma solidity ^0.4.18;
 
 contract Lotto {

     bool public payedOut = false;
     address public winner;
     uint public winAmount;

     // ... extra functionality here

     function sendToWinner() public {
    require(!payedOut, "Payment already made");
    
    // Using transfer() instead of send() for better security
    // transfer() automatically reverts on failure and has gas limit of 2300
    winner.transfer(winAmount);
    
    // State update after transfer to follow checks-effects-interactions pattern
    payedOut = true;
}

     function withdrawLeftOver() public {
         require(payedOut);
         // <yes> <report> UNCHECKED_LL_CALLS
         msg.sender.send(this.balance);
     }
 }
