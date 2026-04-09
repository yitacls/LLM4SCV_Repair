pragma solidity ^0.8.0;

contract M_BANK {
    struct Holder {
        uint unlockTime;
        uint balance;
    }
    
    mapping(address => Holder) public Acc;
    Log LogFile;
    uint public MinSum = 1 ether;
    
    constructor(address log) {
        LogFile = Log(log);
    }
    
    function Put(uint _unlockTime) public payable {
        Holder storage acc = Acc[msg.sender];
        acc.balance += msg.value;
        acc.unlockTime = _unlockTime > block.timestamp ? _unlockTime : block.timestamp;
        LogFile.AddMessage(msg.sender, msg.value, "Put");
    }
    
    function Collect(uint _am) public payable {
        Holder storage acc = Acc[msg.sender];
        if (acc.balance >= MinSum && acc.balance >= _am && block.timestamp > acc.unlockTime) {
            acc.balance -= _am;
            LogFile.AddMessage(msg.sender, _am, "Collect");
            payable(msg.sender).transfer(_am);
        }
    }
    
    receive() external payable {
        Put(0);
    }
}

contract Log {
    struct Message {
        address Sender;
        string Data;
        uint Val;
        uint Time;
    }
    
    Message[] public History;
    Message LastMsg;
    
    function AddMessage(address _adr, uint _val, string memory _data) public {
        LastMsg.Sender = _adr;
        LastMsg.Time = block.timestamp;
        LastMsg.Val = _val;
        LastMsg.Data = _data;
        History.push(LastMsg);
    }
}

In the repaired code:
- Updated the pragma version to ^0.8.0.
- Used `block.timestamp` instead of `now`.
- Replaced the `call.value` with `payable(msg.sender).transfer(_am)` for security.
- Made necessary adjustments for compatibility with Solidity 0.8.0.
- Ensured the code maintains the original logic while addressing vulnerabilities.