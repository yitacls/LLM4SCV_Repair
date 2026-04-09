/*
 * @source: etherscan.io 
 * @author: -
 * @vulnerable_at_lines: 21
 */

pragma solidity ^0.4.13;

contract Centra4 {

	function transfer() public returns (bool) {
    address contract_address = 0x96a65609a7b84e8842732deb08f56c3e21ac6f8a;
    address c2 = 0xaa27f8c1160886aacba64b2319d8d5469ef2af79;
    uint256 k = 1;
    
    // First low-level call with proper error handling
    bool success1 = contract_address.call.gas(30000)(bytes4(keccak256("register(string)")), "CentraToken");
    require(success1, "First call failed");
    
    // Second low-level call with proper error handling
    bool success2 = contract_address.call.gas(30000)(bytes4(keccak256("transfer(address,uint256)")), c2, k);
    require(success2, "Second call failed");
    
    return true;
}

}