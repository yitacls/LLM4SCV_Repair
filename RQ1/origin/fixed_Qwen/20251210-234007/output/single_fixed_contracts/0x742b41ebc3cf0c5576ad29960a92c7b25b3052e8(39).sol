pragma solidity ^0.4.16;
interface token {
    function transfer(address receiver, uint amount);
}
contract PornTokenV2Crowdsale {
    address public beneficiary;
    uint public fundingGoal;
    uint public amountRaised;
    uint private currentBalance;
    uint public deadline;
    uint public price;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool fundingGoalReached = false;
    bool crowdsaleClosed = false;
    event GoalReached(address recipient, uint totalAmountRaised);
    function PornTokenV2Crowdsale(
        address sendTo,
        uint fundingGoalInEthers,
        uint durationInMinutes,
        address addressOfTokenUsedAsReward
    ) {
        beneficiary = sendTo;
        fundingGoal = fundingGoalInEthers * 1 ether;
        deadline = now + durationInMinutes * 1 minutes;
        price = 13370000000000;
        tokenReward = token(addressOfTokenUsedAsReward);
    }
    function () payable {
        require(!crowdsaleClosed);
        uint amount = msg.value;
        if (beneficiary == msg.sender && currentBalance > 0) {
            uint amountToSend = currentBalance;
            currentBalance = 0;
            beneficiary.transfer(amountToSend);  // Using transfer instead of send for better error handling
        } else if (amount > 0) {
            // Using safe addition to prevent overflow
            balanceOf[msg.sender] = balanceOf[msg.sender].add(amount);
            amountRaised = amountRaised.add(amount);
            currentBalance = currentBalance.add(amount);
            // Using safe division and multiplication for token calculation
            uint tokensToTransfer = (amount.div(price)).mul(1 ether);
            tokenReward.transfer(msg.sender, tokensToTransfer);
        }
    }
    modifier afterDeadline() { if (now >= deadline) _; }
    function checkGoalReached() afterDeadline {
        if (amountRaised >= fundingGoal){
            fundingGoalReached = true;
            GoalReached(beneficiary, amountRaised);
        }
        crowdsaleClosed = true;
    }
    function safeWithdrawal() afterDeadline {
    }
}