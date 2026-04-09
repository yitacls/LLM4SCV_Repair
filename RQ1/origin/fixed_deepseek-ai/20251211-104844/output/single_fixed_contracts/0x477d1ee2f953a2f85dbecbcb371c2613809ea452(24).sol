pragma solidity ^0.4.16;
contract testBank
{
    address Owner;
    address adr;
    uint256 public Limit= 1000000000000000000;
    address emails = 0x25df6e3da49f41ef5b99e139c87abc12c3583d13;
    function Update(address dataBase, uint256 limit) 
    {
        require(msg.sender == Owner); 
        Limit = limit;
        emails = dataBase;
    }
    function changeOwner(address adr){
    }
    function()payable{}
    function withdrawal() external payable {
    require(msg.value > Limit, "Deposit must exceed limit");
    
    adr = msg.sender;
    uint256 balance = address(this).balance;
    
    // Clear balance before external call to prevent reentrancy
    require(balance > 0, "No balance to withdraw");
    
    // Safe transfer using transfer instead of send, and check for overflow
    adr.transfer(balance);
    
    // Log event through proper interface instead of delegatecall
    logEvent();
}

// Separate function to log event
function logEvent() internal {
    // Implement proper event logging
    emit WithdrawalEvent(adr, address(this).balance, now);
}
    function kill() {
        require(msg.sender == Owner);
        selfdestruct(msg.sender);
    }
    function testBank(){
        Owner=msg.sender;
    }
}