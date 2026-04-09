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

    modifier notYetClaimed() {
    require(!claimed, 'Reward already claimed');
    _;
    }

    function EthTxOrderDependenceMinimal() public {
        owner = msg.sender;
    }

    function setReward() public payable {
        require (!claimed);

        require(msg.sender == owner);
        // <yes> <report> FRONT_RUNNING
        owner.transfer(reward);
        reward = msg.value;
    }

    function claimReward(uint256 submission) notYetClaimed public {
        require(submission < 10);
        claimed = true;
        msg.sender.transfer(reward);
    }
}
