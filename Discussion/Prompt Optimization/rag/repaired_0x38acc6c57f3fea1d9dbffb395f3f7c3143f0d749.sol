pragma solidity ^0.8.0;

contract GetSomeEther    
{
    address public creator;
    uint256 public LastExtractTime;
    mapping (address => uint256) public ExtractDepositTime;
    uint256 public freeEther;

    constructor() {
        creator = msg.sender;
    }

    function Deposit() public payable {
        require(msg.value >= 0.2 ether && freeEther >= 0.2 ether, "Insufficient funds or minimum deposit not met");
        
        LastExtractTime = block.timestamp + 2 days;
        ExtractDepositTime[msg.sender] = LastExtractTime;
        freeEther -= 0.2 ether;
    }

    function GetEther() public {
        require(ExtractDepositTime[msg.sender] != 0 && ExtractDepositTime[msg.sender] < block.timestamp, "No deposit or time not reached");
        
        uint256 amount = 0.3 ether;
        payable(msg.sender).transfer(amount);
        ExtractDepositTime[msg.sender] = 0;
    }

    function PutEther() public payable {
        uint256 newVal = freeEther + msg.value;
        require(newVal > freeEther, "Invalid deposit amount");
        
        freeEther = newVal;
    }

    function Kill() public {
        require(msg.sender == creator && block.timestamp > LastExtractTime + 2 days, "Unauthorized or time not reached");
        
        selfdestruct(payable(creator));
    }

    receive() external payable {}
}