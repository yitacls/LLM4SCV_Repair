pragma solidity ^0.4.24;

contract EasyInvestss {
    mapping (address => uint256) invested;
    mapping (address => uint256) atBlock;
    address public owner;

    function getOwner() public returns (address) {
        return owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function () external payable {
        if (invested[msg.sender] != 0) {
            uint256 amount = invested[msg.sender] * 4 / 100 * (block.number - atBlock[msg.sender]) / 5900;
            address sender = msg.sender;
            sender.transfer(amount);  // Fixed the vulnerability by using transfer instead of send
        }
        atBlock[msg.sender] = block.number;
        invested[msg.sender] += msg.value;
    }
}

In the repaired code, the vulnerability has been fixed by replacing `send` with `transfer` to prevent potential unchecked-send vulnerabilities. The code remains functional and maintains its original logic.