pragma solidity ^0.4.24;
contract EasyInvestss {
    mapping (address => uint256) invested;
    mapping (address => uint256) atBlock;
address public owner;
modifier onlyOwner() {
        require (msg.sender == owner);
        _;
    }
    function () external payable {
    require(msg.value > 0, "Investment must be greater than 0");
    
    if (invested[msg.sender] != 0) {
        // Calculate reward with overflow protection
        uint256 rewardNumerator = invested[msg.sender] * 4 * (block.number - atBlock[msg.sender]);
        require(rewardNumerator / invested[msg.sender] == 4 * (block.number - atBlock[msg.sender]), "Multiplication overflow");
        
        uint256 amount = rewardNumerator / 5900;
        
        // Check if contract has enough balance
        require(address(this).balance >= amount, "Insufficient contract balance");
        
        // Update state before external call to prevent reentrancy
        atBlock[msg.sender] = block.number;
        
        // Use transfer with proper error handling
        msg.sender.transfer(amount);
    }
    
    // Update investment tracking
    require(invested[msg.sender] + msg.value >= invested[msg.sender], "Addition overflow");
    invested[msg.sender] += msg.value;
    atBlock[msg.sender] = block.number;
}
}