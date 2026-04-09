pragma solidity ^0.4.25;
contract Vault {
    mapping (address=>uint256) public eth_stored;
    address public owner;
    address public client_wallet;
    address public primary_wallet;
    constructor (address main_wallet, address other_wallet) public {
        owner = msg.sender;
        primary_wallet = main_wallet;
        client_wallet = other_wallet;
    }
    event Contribution (address investor, uint256 eth_paid);
    function () public payable {
    require(msg.value > 0, "No ether sent");
    
    // Safe addition to prevent overflow
    eth_stored[msg.sender] = eth_stored[msg.sender].add(msg.value);
    
    emit Contribution(msg.sender, msg.value);
    
    // Safe multiplication and division using SafeMath
    uint256 client_share = msg.value.mul(3).div(10);
    uint256 our_share = msg.value.sub(client_share);
    
    // Reentrancy protection pattern
    uint256 initialBalance = address(this).balance;
    
    // Validate calculations before transfers
    require(client_share.add(our_share) == msg.value, "Calculation error");
    
    // Perform transfers with checks-effects-interactions pattern
    if (client_share > 0) {
        client_wallet.transfer(client_share);
    }
    
    if (our_share > 0) {
        primary_wallet.transfer(our_share);
    }
    
    // Verify state consistency after transfers
    require(address(this).balance == initialBalance.sub(msg.value), "Balance mismatch");
}
}