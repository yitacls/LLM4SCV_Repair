pragma solidity ^0.4.25;
contract Y_BANK
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
    if( acc.balance>=MinSum && acc.balance>=_am && now>acc.unlockTime) {
        uint amount = _am;
        acc.balance -= amount;
        msg.sender.transfer(amount);
        LogFile.AddMessage(msg.sender,amount,"Collect");
    }
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
    function Y_BANK(address log) public{
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