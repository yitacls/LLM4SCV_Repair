/*
 * @source: https://github.com/sigp/solidity-security-blog
 * @author: -
 * @vulnerable_at_lines: 18,20
 */

pragma solidity ^0.4.25;

contract Roulette {
    uint public pastBlockTime; // Forces one bet per block

    constructor() public payable {} // initially fund contract

    // fallback function used to make a bet
    function () public payable {
    require(msg.value == 10 ether); // must send 10 ether to play
    require(block.number != pastBlockNumber); // only 1 transaction per block
    pastBlockNumber = block.number;
    if(block.number % 15 == 0) { // winner
        msg.sender.transfer(address(this).balance);
    }
}
}
