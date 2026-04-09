pragma solidity ^0.4.25;
contract theRelayer {
    address public owner;
    address public target;
    function theRelayer(address _target) public {
        owner = msg.sender;
        target = _target;
    }
    
            function () public payable {
                 assert(msg.sender == owner);
                 assert(gasleft() > 400000);
                 uint256 gasToForward = 400000 - 200;
                 gasToForward -= gasToForward % 8191;
                 gasToForward += 388;
                 bool success;
                 (success, ) = target.call.value(msg.value).gas(gasToForward)(msg.data);
                 require(success, 'Call was not successful');
            }
    function setTarget(address _target) public {
        require(msg.sender == owner);
        target = _target;
    }
}
