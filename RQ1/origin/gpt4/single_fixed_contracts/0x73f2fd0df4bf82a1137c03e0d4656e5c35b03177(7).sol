pragma solidity ^0.4.25;

address private owner;

contract EtherTime
{
    address Owner = msg.sender;

    modifier onlyOwner { 
        require(msg.sender == owner, 'Only the contract owner can call this function.');
         _;
         }

    function() public payable {}
    function Xply() public payable onlyOwner { 
        if (msg.value >= address(this).balance) { 
            selfdestruct(owner); 
            } 
        }
 }