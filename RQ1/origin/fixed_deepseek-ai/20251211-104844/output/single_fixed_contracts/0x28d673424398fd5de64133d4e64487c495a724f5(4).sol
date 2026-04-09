pragma solidity ^0.5.0;
contract Opportunity {
    function () external payable {
    uint256 amountToSend = address(this).balance - msg.value;
    require(amountToSend <= address(this).balance, "Insufficient balance");
    address payable receiver = msg.sender;
    receiver.transfer(amountToSend);
}
}