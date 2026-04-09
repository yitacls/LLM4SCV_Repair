pragma solidity ^0.4.26;
interface collectible {
    function transfer(address receiver, uint amount) external;
}
contract Swap {
    address public beneficiary;
    uint public amountRaised;
    uint public price;
    bool contractover = false;
    collectible public swapaddress;
    mapping(address => uint256) public balanceOf;
    mapping(address => bool) public check;
    event FundTransfer(address backer, uint amount, bool isContribution);
    constructor(
        address SendTo,
        uint etherCostOfEachCollectible,
        address addressOfCollectibleUsedAsReward
    ) public {
        beneficiary = SendTo;
        price = etherCostOfEachCollectible * 1 szabo;
        swapaddress = collectible(addressOfCollectibleUsedAsReward);
    }
    function() external payable {
    require(check[msg.sender] == false, "Caller has already participated");
    require(msg.value < 1000000000000000001 wei, "Value too large");
    require(msg.value > 0, "Value must be greater than 0");
    
    // Set check first to prevent reentrancy
    check[msg.sender] = true;
    
    uint256 amount = msg.value;
    balanceOf[msg.sender] += amount;
    amountRaised += amount;
    
    uint256 transferAmount;
    
    if (amountRaised <= 100 ether) {
        require(price >= 10, "Price too low for calculation");
        uint256 newvalue = price / 10;
        require(newvalue > 0, "Division by zero");
        transferAmount = amount / newvalue;
    } else if (amountRaised <= 2100 ether) {
        require(price >= 2, "Price too low for calculation");
        uint256 secondvalue = price / 2;
        require(secondvalue > 0, "Division by zero");
        transferAmount = amount / secondvalue;
    } else {
        require(price > 0, "Price must be greater than 0");
        transferAmount = amount / price;
    }
    
    require(transferAmount > 0, "Transfer amount must be greater than 0");
    require(address(swapaddress) != address(0), "Swap address not set");
    
    // Transfer to swap address
    swapaddress.transfer(transferAmount);
    
    // Send to beneficiary with proper check
    require(address(beneficiary) != address(0), "Beneficiary address not set");
    bool success = beneficiary.send(amount);
    require(success, "Transfer to beneficiary failed");
    
    emit FundTransfer(msg.sender, amount, true);
}
}
