pragma solidity ^0.5.0;
contract Opportunity {
    function () external payable {
        uint256 amount = address(this).balance - msg.value;
        (bool success, ) = msg.sender.call.value(amount)("");
        require(success, "Transfer failed");
    }
}