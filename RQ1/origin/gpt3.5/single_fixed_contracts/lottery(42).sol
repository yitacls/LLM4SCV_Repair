/*
 * @article: https://blog.positive.com/predicting-random-numbers-in-ethereum-smart-contracts-e5358c6b8620
 * @source: https://etherscan.io/address/0x80ddae5251047d6ceb29765f38fed1c0013004b7#code
 * @vulnerable_at_lines: 38,42
 * @author: -
 */

 //added pragma version
  pragma solidity ^0.4.0;
  
 contract Lottery {
     event GetBet(uint betAmount, uint blockNumber, bool won);

     struct Bet {
         uint betAmount;
         uint blockNumber;
         bool won;
     }

     address private organizer;
     Bet[] private bets;

     // Create a new lottery with numOfBets supported bets.
     function Lottery() {
         organizer = msg.sender;
     }

     // Fallback function returns ether
     function() {
         throw;
     }

     // Make a bet
     function makeBet() public payable {
    uint256 blockValue = uint256(blockhash(block.number-1));
    bool won = (blockValue % 2) == 0;

    bets.push(Bet(msg.value, block.number, won));

    if (won) {
        if (!payable(msg.sender).send(msg.value)) {
            revert("Failed to send Ether");
        }
    }
}

     // Get all bets that have been made
     function getBets() {
         if(msg.sender != organizer) { throw; }

         for (uint i = 0; i < bets.length; i++) {
             GetBet(bets[i].betAmount, bets[i].blockNumber, bets[i].won);
         }
     }

     // Suicide :(
     function destroy() {
         if(msg.sender != organizer) { throw; }

         suicide(organizer);
     }
 }
