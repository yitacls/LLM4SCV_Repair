/*
 * @article: https://blog.positive.com/predicting-random-numbers-in-ethereum-smart-contracts-e5358c6b8620
 * @source: https://etherscan.io/address/0xa11e4ed59dc94e69612f3111942626ed513cb172#code
 * @vulnerable_at_lines: 43
 * @author: -
 */

 pragma solidity ^0.4.15;

/// @title Ethereum Lottery Game.

contract EtherLotto {

    // Amount of ether needed for participating in the lottery.
    uint constant TICKET_AMOUNT = 10;

    // Fixed amount fee for each lottery game.
    uint constant FEE_AMOUNT = 1;

    // Address where fee is sent.
    address public bank;

    // Public jackpot that each participant can win (minus fee).
    uint public pot;

    // Lottery constructor sets bank account from the smart-contract owner.
    function EtherLotto() {
        bank = msg.sender;
    }

    // Public function for playing lottery. Each time this function
    // is invoked, the sender has an oportunity for winning pot.
    function play() payable {
    // Participants must spend some fixed ether before playing lottery.
    require(msg.value == TICKET_AMOUNT, "Incorrect ticket amount");
    
    // Increase pot for each participant.
    pot += msg.value;
    
    // Improved random number generation using multiple entropy sources
    // Combine blockhash, timestamp, difficulty, nonce, and sender address
    uint256 random = uint256(keccak256(abi.encodePacked(
        blockhash(block.number - 1),
        block.timestamp,
        block.difficulty,
        nonce,
        msg.sender
    ))) % 2;
    
    // Increment nonce to prevent replay attacks
    nonce++;
    
    // Distribution: 50% of participants will be winners.
    if (random == 0) {
        // Send fee to bank account.
        bank.transfer(FEE_AMOUNT);
        
        // Send jackpot to winner.
        msg.sender.transfer(pot - FEE_AMOUNT);
        
        // Restart jackpot.
        pot = 0;
    }
}

}
