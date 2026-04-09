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
    constructor() public {
        organizer = msg.sender;
    }

    // Fallback function returns ether
    function() external {
        revert();
    }

    // Make a bet
    function makeBet() public payable {
        // Won if block number is even
        // (note: this is a terrible source of randomness, please don't use this with real money)
        bool won = (block.number % 2) == 0;

        // Record the bet with an event
        bets.push(Bet(msg.value, block.number, won));

        // Payout if the user won, otherwise take their money
        if(won) {
            if(!msg.sender.send(msg.value)) {
                // Return ether to sender
                revert();
            }
        }
    }

    // Get all bets that have been made
    function getBets() public {
        require(msg.sender == organizer);

        for (uint i = 0; i < bets.length; i++) {
            emit GetBet(bets[i].betAmount, bets[i].blockNumber, bets[i].won);
        }
    }

    // Self-destruct function
    function destroy() public {
        require(msg.sender == organizer);

        selfdestruct(organizer);
    }
}