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
    require(!payedOut);
    winner.transfer(winAmount);
    payedOut = true;
}

       