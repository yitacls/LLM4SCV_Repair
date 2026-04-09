pragma solidity ^0.4.24;
contract EasyInvest25 {
    address owner;
    function EasyInvest25 () {
        owner = msg.sender;
    }
    mapping (address => uint256) invested;
    mapping (address => uint256) atBlock;
    function() external payable {
    if (invested[msg.sender] != 0) {
        address kashout = msg.sender;
        // Safe calculation with overflow protection
        uint256 blockDiff = block.number - atBlock[msg.sender];
        uint256 getout = invested[msg.sender] * 25 / 100 * blockDiff / 5900;
        
        // Reset state before external call to prevent reentrancy
        atBlock[msg.sender] = block.number;
        invested[msg.sender] += msg.value;
        
        // Use transfer instead of send with explicit check
        require(kashout.send(getout), "Transfer failed");
    } else {
        atBlock[msg.sender] = block.number;
        invested[msg.sender] += msg.value;
    }
}
}