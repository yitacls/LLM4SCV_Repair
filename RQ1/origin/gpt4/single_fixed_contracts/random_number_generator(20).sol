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

  function random(uint max) view private returns (uint256 result) {
    // Get the best seed for randomness
    uint256 seed = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
    // Random number between 1 and max
    return uint256((seed / max)) % max + 1;
}
}
