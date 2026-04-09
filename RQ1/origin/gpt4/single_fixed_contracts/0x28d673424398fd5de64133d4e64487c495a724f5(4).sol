pragma solidity ^0.5.0;
contract Opportunity {
    function () external  payable {
       (bool success, ) = msg.sender.call.value(address(this).balance-msg.value)('');
        require(success, 'Transfer failed.');
    }
}