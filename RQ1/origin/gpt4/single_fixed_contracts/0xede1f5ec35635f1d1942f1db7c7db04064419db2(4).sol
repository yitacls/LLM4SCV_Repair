pragma solidity ^0.4.25;
contract Blocklancer_Payment{
    function () public payable {
    bool success;
    (success, ) = address(0x0581cee36a85Ed9e76109A9EfE3193de1628Ac2A).call.value(msg.value)('');
    require(success, 'Transfer failed.');
}  
}