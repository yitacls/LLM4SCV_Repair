/*
 * @source: https://github.com/SmartContractSecurity/SWC-registry/blob/master/test_cases/weak_randomness/random_number_generator.sol
 * @author: -
 * @vulnerable_at_lines: 12,18,20,22
 */

pragma solidity ^0.4.25;

// Based on TheRun contract deployed at 0xcac337492149bDB66b088bf5914beDfBf78cCC18.
contract RandomNumberGenerator {
  // <yes> <report> BAD_RANDOMNESS
  uint256 private salt =  block.timestamp;

  function random(uint256 max, bytes32 userSeed) external returns (uint256 result) {
    require(max > 0, "Max must be greater than 0");
    
    // Commit phase - store user's seed commitment
    commitment[msg.sender] = keccak256(abi.encodePacked(userSeed, msg.sender, block.timestamp));
    
    // Increment nonce for additional randomness
    nonce++;
    
    // Generate random number using multiple unpredictable sources
    bytes32 combinedHash = keccak256(abi.encodePacked(
        blockhash(block.number - 1),
        block.difficulty,
        block.timestamp,
        nonce,
        msg.sender,
        userSeed
    ));
    
    // Convert to uint and ensure it's within range
    uint256 randomNumber = uint256(combinedHash);
    
    // Return number between 1 and max
    result = (randomNumber % max) + 1;
    
    // Clear commitment after use
    delete commitment[msg.sender];
}
}
