/*
 * @source: https://github.com/ConsenSys/evm-analyzer-benchmark-suite
 * @author: Suhabe Bugrara
 * @vulnerable_at_lines: 23,31
 */

pragma solidity ^0.4.16;

contract EthTxOrderDependenceMinimal {
    address public owner;
    bool public claimed;
    uint public reward;

    function EthTxOrderDependenceMinimal() public {
        owner = msg.sender;
    }

    function setReward() public payable {
        require(!claimed);
        require(msg.sender == owner);
        
        uint256 currentReward = reward;  // Store current reward locally
        reward = msg.value;  // Update reward with new value
        
        owner.transfer(currentReward);  // Transfer the previously stored reward
    }

    function claimReward(uint256 submission) {
        require (!claimed);
        require(submission < 10);
        // <yes> <report> FRONT_RUNNING
        msg.sender.transfer(reward);
        claimed = true;
    }
}
