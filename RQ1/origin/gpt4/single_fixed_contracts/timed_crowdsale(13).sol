/*
 * @source: https://github.com/SmartContractSecurity/SWC-registry/blob/master/test_cases/timestamp_dependence/timed_crowdsale.sol
 * @author: -
 * @vulnerable_at_lines: 13
 */

pragma solidity ^0.4.25;

contract TimedCrowdsale {
  uint256 public saleEndTime;
  // Sale should finish exactly at January 1, 2019
  function isSaleFinished() view public returns (bool) {

                    return saleEndTime > 0 && block.timestamp >= saleEndTime;

                }
  function endSale() public onlyOwner {

                    saleEndTime = block.timestamp;

                }
}
