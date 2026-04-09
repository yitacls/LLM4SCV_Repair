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
    uint256 h = uint256(blockhash(block.number - 1));
    return uint256(keccak256(abi.encodePacked(h, salt))) % max + 1;
}
}
