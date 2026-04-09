pragma solidity ^0.4.25;
contract wallet {
    address owner;
    function wallet() {
        owner = msg.sender;
    }
    function transfer(address target) payable {
        target.transfer(msg.value);
    }
    function kill() {
        if (msg.sender == owner) {
            suicide(owner);
        } else {
            throw;
        }
    }
}