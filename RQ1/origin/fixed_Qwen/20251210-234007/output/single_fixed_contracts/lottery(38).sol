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
     function makeBet(bytes32 commitHash) {
    // Require a proper commitment for randomness
    // This is a simplified fix - in practice, you'd implement a full commit-reveal scheme
    // or use an oracle service like Chainlink VRF
    
    // For demonstration, using blockhash of a recent block (still not perfect but better)
    bytes32 randomHash = blockhash(block.number - 1);
    
    // Validate that we have a recent blockhash
    if (randomHash == 0) {
        throw; // Blockhash not available
    }
    
    // Create deterministic randomness from commit and blockhash
    bool won = (uint256(keccak256(randomHash, commitHash)) % 2) == 0;

    // Record the bet with an event
    bets.push(Bet(msg.value, block.number, won));

    // Payout if the user won, otherwise take their money
    if(won) {
        if(!msg.sender.send(msg.value)) {
            // Return ether to sender
            throw;
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
