contract SmartFix {
  address public smartfix_owner = msg.sender;
}

/*
 * @source: https://github.com/sigp/solidity-security-blog
 * @author: -
 * @vulnerable_at_lines: 18,20
 */

pragma solidity ^0.4.25;

contract Roulette is SmartFix {
    uint public pastBlockTime; // Forces one bet per block

    constructor() public payable {} // initially fund contract

    // fallback function used to make a bet
    function () public payable {
        require((smartfix_owner == msg.sender)); /* <FIX> Insert */
        require(msg.value == 10 ether); // must send 10 ether to play
        // <yes> <report> TIME_MANIPULATION
        require(now != pastBlockTime); // only 1 transaction per block
        // <yes> <report> TIME_MANIPULATION
        pastBlockTime = now;
        if(now % 15 == 0) { // winner
            msg.sender.transfer(this.balance);
        }
    }
}
