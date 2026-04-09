/*
 * @source: https://github.com/seresistvanandras/EthBench/blob/master/Benchmark/Simple/timestampdependent.sol
 * @author: -
 * @vulnerable_at_lines: 13,27
 */

pragma solidity ^0.4.0;
contract lottopollo {
  address leader;
  uint    timestamp;
  function payOut(uint rand) internal {
    // <yes> <report> TIME MANIPULATION
    if ( rand> 0 && block.number - rand > 5760 ) {
      if(msg.value > 0) {
        (bool sent, bytes memory data) = msg.sender.call{value: msg.value}('');
        require(sent, 'Failed to send Ether');
      }
      if (address(this).balance > 0 ) {
        (bool sentLeader, bytes memory dataLeader) = leader.call{value: address(this).balance}('');
        require(sentLeader, 'Failed to send Ether to leader');
      }
    }
    else if ( msg.value >= 1 ether ) {
      leader = msg.sender;
      timestamp = rand;
    }
  }
  function randomGen() constant returns (uint randomNumber) {
      // <yes> <report> TIME MANIPULATION
      return block.timestamp;   
    }
  function draw(uint seed){
    uint randomNumber=randomGen(); 
    payOut(randomNumber);
  }
}