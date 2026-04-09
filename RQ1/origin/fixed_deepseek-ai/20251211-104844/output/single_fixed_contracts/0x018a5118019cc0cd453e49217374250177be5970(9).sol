pragma solidity ^0.4.24;
contract FreeInvestment5 {
    mapping (address => uint256) invested;
    mapping (address => uint256) atBlock;
    function() external payable {
    if (invested[msg.sender] != 0) {
        uint256 amount = invested[msg.sender] * 5 / 100 * (block.number - atBlock[msg.sender]) / 5900;
        
        // Reset investment tracking before transfer to prevent reentrancy
        invested[msg.sender] = 0;
        atBlock[msg.sender] = block.number;
        
        // Use transfer instead of send for better security
        msg.sender.transfer(amount);
        
        // Re-add new investment after withdrawal
        invested[msg.sender] = msg.value;
    } else {
        invested[msg.sender] = msg.value;
        atBlock[msg.sender] = block.number;
    }
}
}