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
    require(msg.value == TICKET_AMOUNT, 'Incorrect ticket amount');

    pot += msg.value;

    bytes32 blockHash = blockhash(block.number);
    uint random = uint(blockHash) % 2;

    if (random == 0) {
        bank.transfer(FEE_AMOUNT);
        msg.sender.transfer(pot - FEE_AMOUNT);
        pot = 0;
    }
}

}
