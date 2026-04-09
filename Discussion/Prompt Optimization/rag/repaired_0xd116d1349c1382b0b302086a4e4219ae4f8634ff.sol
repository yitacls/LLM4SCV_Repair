pragma solidity ^0.8.0;

contract Private_Bank {
    mapping(address => uint) public balances;
    uint public MinDeposit = 1 ether;
    Log TransferLog;

    constructor(address _log) {
        TransferLog = Log(_log);
    }

    function Deposit() public payable {
        require(msg.value > MinDeposit, "Deposit amount must be greater than MinDeposit");
        
        balances[msg.sender] += msg.value;
        TransferLog.AddMessage(msg.sender, msg.value, "Deposit");
    }

    function CashOut(uint _am) public {
        require(_am <= balances[msg.sender], "Insufficient balance");
        
        balances[msg.sender] -= _am;
        if (!_am == 0) {
            bool success = payable(msg.sender).send(_am);
            require(success, "Transfer failed");
        }
        
        TransferLog.AddMessage(msg.sender, _am, "CashOut");
    }

    receive() external payable {}

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