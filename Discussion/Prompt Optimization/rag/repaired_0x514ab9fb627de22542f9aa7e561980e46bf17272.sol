pragma solidity ^0.4.25;

contract wallet {
    address owner;

    function wallet() {
        owner = msg.sender;
    }

    function transfer(address target) payable {
        require(target.call.value(msg.value)());  // fixed line
    }

    function kill() {
        if (msg.sender == owner) {
            selfdestruct(owner);
        } else {
            revert();
        }
    }
}