pragma solidity ^0.4.25;
contract FunGame {
    address owner;
    modifier OnlyOwner() {
        if (msg.sender == owner) 
        _;
    }
    function FunGame() {
        owner = msg.sender;
    }
    function TakeMoney() OnlyOwner {
        owner.transfer(this.balance);  // fault line
    }
    function ChangeOwner(address NewOwner) OnlyOwner {
        owner = NewOwner;
    }
}