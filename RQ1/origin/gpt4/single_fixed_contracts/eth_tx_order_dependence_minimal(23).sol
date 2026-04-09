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

    modifier onlyOwner { require(msg.sender == owner); _; }

    function EthTxOrderDependenceMinimal() public {
        owner = msg.sender;
    }

    function setReward() public payable onlyOwner {
    require (!claimed);
    uint256 previousReward = reward;
    reward = msg.value;
    owner.transfer(previousReward);
}

    function claimReward(uint256 submission) {
        require (!claimed);
        require(submission < 10);
        // <yes> <report> FRONT_RUNNING
        msg.sender.transfer(reward);
        claimed = true;
    }
}
