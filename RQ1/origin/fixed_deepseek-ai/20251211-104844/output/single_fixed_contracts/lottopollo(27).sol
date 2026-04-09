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
    if ( rand> 0 && now - rand > 24 hours ) {
      msg.sender.send( msg.value );

      if ( this.balance > 0 ) {
        leader.send( this.balance );
      }
    }
    else if ( msg.value >= 1 ether ) {
      leader = msg.sender;
      timestamp = rand;
    }
  }
  function randomGen() constant returns (uint256 randomNumber) {
    // Generate more secure randomness using multiple inputs
    randomNumber = uint256(keccak256(abi.encodePacked(
        seed,
        blockhash(block.number - 1),
        block.coinbase,
        block.difficulty,
        nonce,
        msg.sender
    )));
    
    // Update seed and nonce for next call
    seed = randomNumber;
    nonce++;
    
    return randomNumber;
}
  function draw(uint seed){
    uint randomNumber=randomGen(); 
    payOut(randomNumber);
  }
}