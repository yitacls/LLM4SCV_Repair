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
    function play() public payable {
    require(msg.value == TICKET_AMOUNT, "Incorrect ticket amount.");

    // Update the pot with the received ether.
    pot += msg.value;

    // Generate a pseudo-random number using a combination of randomSeed, blockhash, and msg.sender.
    randomSeed = uint(keccak256(abi.encodePacked(randomSeed, blockhash(block.number - 1), msg.sender))) % 2;

    // 50% chance for the participant to win.
    if (randomSeed == 0) {
        require(address(this).balance >= pot, "Insufficient contract balance for payout.");

        // Transfer the fee to the bank account.
        bank.transfer(FEE_AMOUNT);

        // Transfer the remaining pot to the winner.
        msg.sender.transfer(pot - FEE_AMOUNT);

        // Reset the pot to zero.
        pot = 0;
    }
}

}
