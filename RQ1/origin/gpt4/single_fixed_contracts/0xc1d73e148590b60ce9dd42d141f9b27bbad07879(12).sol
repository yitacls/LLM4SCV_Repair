pragma solidity ^0.4.22;
contract EthReceiver
{
    bool closed = false;
    uint unlockTime = 43200;
    address sender;
    address receiver;
    import "github.com/OpenZeppelin/zeppelin-solidity/contracts/math/SafeMath.sol";function Put(address _receiver) public payable {    require(msg.value <= 0.5 ether, "Cannot send more than 0.5 ether");    require(_receiver != address(0), "Invalid receiver address");    if (!closed || msg.sender == address(0)) {        sender = msg.sender;        receiver = _receiver;        unlockTime = SafeMath.add(unlockTime, now);    }}
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