pragma solidity ^0.5.0;
contract Opportunity {
    function () external payable {
    require(msg.value == address(this).balance);
    // Proceed with intended logic
}
}