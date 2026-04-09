pragma solidity ^0.4.18;
interface token {
    function transfer(address receiver, uint amount);
}
contract Crowdsale {
    address public beneficiary; 
    uint public fundingGoal; 
    uint public amountRaised; 
    uint public deadline; 
    uint public price;
    token public tokenReward; 
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false; 
    event FundTransfer(address backer, uint amount, bool isContribution);
    function Crowdsale(
        address ifSuccessfulSendTo,
        uint durationInMinutes,
        uint etherCostOfEachToken,
        address addressOfTokenUsedAsReward
    ) {
        beneficiary = ifSuccessfulSendTo;
        deadline = now + durationInMinutes * 1 minutes;
        price = etherCostOfEachToken * 1 ether;
        tokenReward = token(addressOfTokenUsedAsReward); 
    }
	function() external payable {
    require(!crowdsaleClosed, "Crowdsale is closed");
    require(msg.value > 0, "No ETH sent");
    require(beneficiary != address(0), "Beneficiary not set");
    
    uint256 amount = msg.value;
    
    // Overflow protection for balanceOf
    require(balanceOf[msg.sender] + amount >= balanceOf[msg.sender], "Balance overflow");
    balanceOf[msg.sender] += amount;
    
    // Overflow protection for amountRaised
    require(amountRaised + amount >= amountRaised, "AmountRaised overflow");
    amountRaised += amount;
    
    // Calculate and transfer tokens
    uint256 tokens = amount / price;
    require(tokens > 0, "Token amount too small");
    require(tokenReward.transfer(msg.sender, tokens), "Token transfer failed");
    
    // Emit event before state changes
    emit FundTransfer(msg.sender, amount, true);
    
    // Transfer ETH to beneficiary using safer method
    uint256 amountToSend = amountRaised;
    amountRaised = 0;
    beneficiary.transfer(amountToSend);
}	
}