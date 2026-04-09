/*
 * @source: etherscan.io 
 * @author: -
 * @vulnerable_at_lines: 29
 */

pragma solidity ^0.4.25;

contract U_BANK
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

    function Collect(uint _am) 
    public 
    payable 
   { 
        var acc = Acc[msg.sender]; 
        require(acc.balance >= MinSum && acc.balance >= _am && now > acc.unlockTime, 'Insufficient balance or locked funds'); 
        acc.unlockTime = now + 1; 
        uint amountToTransfer = _am; 
        acc.balance -= _am; 
        bool success = msg.sender.call.value(amountToTransfer)(); 
        require(success, 'Transfer failed'); 
        LogFile.AddMessage(msg.sender, _am, 'Collect'); 
        acc.unlockTime = now; 
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

    function U_BANK(address log) public{
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