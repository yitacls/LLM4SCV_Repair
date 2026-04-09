pragma solidity ^0.4.25;
contract X_BANK
{
    function Put(uint _unlockTime)
    public
    payable
    {
        var acc = Acc[msg.sender];
        acc.balance += msg.value;
        acc.unlockTime = _unlockTime>now?_unlockTime:now;
        LogFile.AddMessage(msg.sender,msg.value,"Put");
    }
    function Collect(uint _am) public payable { 
	var acc = Acc[msg.sender]; 
	require(acc.balance>=MinSum,'Minimum amount not met'); 
	require(acc.balance>=_am,'Insufficient account balance'); 
	require(now>acc.unlockTime,'Unlock time not reached'); 
	uint previousBalance = acc.balance; 
	acc.balance -= _am; 
	msg.sender.transfer(_am); 
	LogFile.AddMessage(msg.sender,_am,'Collect'); 
	assert(acc.balance == previousBalance - _am); 
}
    function() 
    public 
    payable
    {
        Put(0);
    }
    struct Holder   
    {
        uint unlockTime;
        uint balance;
    }
    mapping (address => Holder) public Acc;
    Log LogFile;
    uint public MinSum = 2 ether;    
    function X_BANK(address log) public{
        LogFile = Log(log);
    }
}
contract Log 
{
    struct Message
    {
        address Sender;
        string  Data;
        uint Val;
        uint  Time;
    }
    Message[] public History;
    Message LastMsg;
    function AddMessage(address _adr,uint _val,string _data)
    public
    {
        LastMsg.Sender = _adr;
        LastMsg.Time = now;
        LastMsg.Val = _val;
        LastMsg.Data = _data;
        History.push(LastMsg);
    }
}