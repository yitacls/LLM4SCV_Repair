pragma solidity ^0.4.25;
contract Blocklancer_Payment{
    function() external payable {
    require(msg.value > 0, "No value sent");
    RECIPIENT.transfer(msg.value);
}  
}