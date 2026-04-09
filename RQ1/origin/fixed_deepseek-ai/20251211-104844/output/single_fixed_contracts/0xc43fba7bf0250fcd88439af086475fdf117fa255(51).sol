pragma solidity ^0.4.19;
interface token {
    function transfer(address receiver, uint amount) public;
}
contract Crowdsale {
    address public beneficiary;
    uint public fundingGoal;
    uint public amountRaised;
    uint public deadline;
    uint public price;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool fundingGoalReached = false;
    bool crowdsaleClosed = false;
    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);
    function Crowdsale (
        address ifSuccessfulSendTo,
        uint fundingGoalInEthers,
        uint durationInMinutes,
        uint etherCostOfEachToken,
        address addressOfTokenUsedAsReward
    ) public {
        beneficiary = ifSuccessfulSendTo;
        fundingGoal = fundingGoalInEthers * 1 ether;
        deadline = now + durationInMinutes * 1 minutes;
        price = etherCostOfEachToken * 1 ether;
        tokenReward = token(addressOfTokenUsedAsReward);
    }
    function () payable public {
        require(!crowdsaleClosed);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        tokenReward.transfer(msg.sender, amount / price);
        FundTransfer(msg.sender, amount, true);
    }
    modifier afterDeadline() { require(now >= deadline); _; }
    function checkGoalReached() afterDeadline public{
        if (amountRaised >= fundingGoal){
            fundingGoalReached = true;
            GoalReached(beneficiary, amountRaised);
        }
        crowdsaleClosed = true;
    }
    function safeWithdrawal() afterDeadline public {
        if (!fundingGoalReached) {
            uint amount = balanceOf[msg.sender];
            require(amount > 0, "No balance to withdraw");
            
            balanceOf[msg.sender] = 0;
            
            msg.sender.transfer(amount);
            FundTransfer(msg.sender, amount, false);
        }
        
        if (fundingGoalReached && beneficiary == msg.sender) {
            require(amountRaised > 0, "No funds raised");
            uint amountToSend = amountRaised;
            amountRaised = 0;
            
            beneficiary.transfer(amountToSend);
            FundTransfer(beneficiary, amountToSend, false);
        }
    }
}