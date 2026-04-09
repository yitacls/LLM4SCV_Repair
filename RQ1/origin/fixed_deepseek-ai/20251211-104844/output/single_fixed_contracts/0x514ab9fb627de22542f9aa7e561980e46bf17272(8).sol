pragma solidity ^0.4.25;
contract wallet {
    address owner;
    function wallet() {
        owner = msg.sender;
    }
    function transfer(address payable target) payable public {
    require(target.send(msg.value), "Transfer failed");
}
    function kill() {
        if (msg.sender == owner) {
            suicide(owner);
        } else {
            throw;
        }
    }
}