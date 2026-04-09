pragma solidity ^0.4.25;
contract EtherTime
{
    address Owner = msg.sender;
    function() public payable {}
    function Xply() public payable {
    require(msg.sender == Owner, 'Only contract owner can call this function');
    selfdestruct(Owner);
}
 }