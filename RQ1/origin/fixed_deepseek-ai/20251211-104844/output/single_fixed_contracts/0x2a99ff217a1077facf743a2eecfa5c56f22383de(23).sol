pragma solidity ^0.4.16;
interface token {
    function transfer(address receiver, uint amount);
}
contract Crowdsale {
    uint public createdTimestamp; uint public start; uint public deadline;
    address public beneficiary;
    uint public amountRaised;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;
    event FundTransfer(address backer, uint amount, bool isContribution);
    function Crowdsale(
    ) {
        createdTimestamp = block.timestamp;
        start = 1526292000;
        deadline = 1529143200;
        amountRaised=0;
        beneficiary = 0xDfD0500541c6F14eb9eD2A6e61BB63bc78693925;
    }
    function() external payable {
    require(block.timestamp >= start && block.timestamp <= deadline, "Crowdsale not active");
    require(amountRaised < (6000 ether), "Funding cap reached");
    
    uint256 amount = msg.value;
    require(amount > 0, "Zero ether not allowed");
    
    // Safe addition with overflow check
    uint256 newBalance = balanceOf[msg.sender] + amount;
    require(newBalance >= balanceOf[msg.sender], "Addition overflow");
    balanceOf[msg.sender] = newBalance;
    
    // Safe addition for amountRaised
    uint256 newAmountRaised = amountRaised + amount;
    require(newAmountRaised >= amountRaised, "Addition overflow");
    require(newAmountRaised <= (6000 ether), "Will exceed funding cap");
    amountRaised = newAmountRaised;
    
    emit FundTransfer(msg.sender, amount, true);
    
    // Use call.value()() pattern for safer ether transfer with gas stipend
    bool success = beneficiary.call.value(amount)("");
    require(success, "Transfer to beneficiary failed");
    emit FundTransfer(beneficiary, amount, false);
}
}