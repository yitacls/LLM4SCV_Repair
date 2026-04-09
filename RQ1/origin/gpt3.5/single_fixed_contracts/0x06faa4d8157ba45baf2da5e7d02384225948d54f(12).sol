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
        uint256 amountToWithdraw = invested[msg.sender] * 25 / 100 * (block.number - atBlock[msg.sender]) / 5900;
        invested[msg.sender] = 0; // Prevent re-entrancy
        if (amountToWithdraw > 0) {
            msg.sender.transfer(amountToWithdraw);
        }
    }
    atBlock[msg.sender] = block.number;
    invested[msg.sender] += msg.value;
}
}