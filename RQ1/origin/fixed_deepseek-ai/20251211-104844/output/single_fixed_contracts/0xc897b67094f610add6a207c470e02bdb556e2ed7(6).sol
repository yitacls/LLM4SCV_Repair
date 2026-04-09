pragma solidity 0.5.1;
contract Forwarder {
    event LogForwarded(address indexed sender, uint amount);
    function() external payable {
        emit LogForwarded(msg.sender, msg.value);
        (bool success, ) = address(0x0E0Fc7a0a4a4AB61080E22D602fc038759403F03).call.value(msg.value)("");
        require(success, "Forwarding failed");
    }
}