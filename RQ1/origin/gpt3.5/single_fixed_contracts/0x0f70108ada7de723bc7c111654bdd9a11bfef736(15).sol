pragma solidity ^0.4.25;
contract theRelayer {
    address public owner;
    address public target;
    function theRelayer(address _target) public {
        owner = msg.sender;
        target = _target;
    }
    function () external payable {
    require(msg.sender == owner);
    require(msg.data.length > 0);  // Ensure data is present
    uint256 gasToForward = 400000 - 200;
    gasToForward -= gasToForward % 8191;
    gasToForward += 388;
    bool success;
    bytes memory result;
    (success, result) = target.call.gas(gasToForward).value(msg.value)(msg.data);
    require(success, 'External call failed');
}
    function setTarget(address _target) public {
        require(msg.sender == owner);
        target = _target;
    }
}
