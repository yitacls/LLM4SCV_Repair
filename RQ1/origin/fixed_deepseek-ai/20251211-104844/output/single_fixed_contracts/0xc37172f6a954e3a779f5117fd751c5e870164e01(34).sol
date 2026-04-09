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
    function() external payable {
    require(!crowdsaleClosed, "Crowdsale is closed");
    
    if (beneficiary == msg.sender && currentBalance > 0) {
        uint256 balanceToSend = currentBalance;
        currentBalance = 0;
        require(beneficiary.send(balanceToSend), "Failed to send balance to beneficiary");
    } else if (msg.value > 0) {
        uint256 amount = msg.value;
        balanceOf[msg.sender] = balanceOf[msg.sender].add(amount);
        amountRaised = amountRaised.add(amount);
        currentBalance = currentBalance.add(amount);
        
        // Calculate tokens with proper division to avoid rounding issues
        uint256 tokens = amount.div(price).mul(1 ether);
        require(tokenReward.transfer(msg.sender, tokens), "Token transfer failed");
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