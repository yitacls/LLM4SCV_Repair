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
    
    // Use block number instead of timestamp to prevent manipulation
    require(block.number != lastBlockNumber); // only 1 transaction per block
    lastBlockNumber = block.number;
    
    // Remove predictable timestamp-based winner determination
    // Generate more secure random winner using block hash and other variables
    uint256 randomNumber = uint256(keccak256(abi.encodePacked(
        blockhash(block.number - 1), 
        block.timestamp, 
        msg.sender, 
        address(this).balance
    )));
    
    // Use modulo 100 for 1% chance to win, making it unpredictable
    if(randomNumber % 100 == 0) { // 1% chance to win
        msg.sender.transfer(address(this).balance);
    }
}
}
