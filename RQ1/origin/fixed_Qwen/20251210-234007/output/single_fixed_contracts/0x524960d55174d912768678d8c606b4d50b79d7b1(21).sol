/*
 * @source: etherscan.io 
 * @author: -
 * @vulnerable_at_lines: 21
 */

pragma solidity ^0.4.13;

contract Centra4 {

	function transfer() returns (bool) {
		address contract_address;
		contract_address = 0x96a65609a7b84e8842732deb08f56c3e21ac6f8a;
		address c2;
		uint256 k;
		k = 1;
		
		c2 = 0xaa27f8c1160886aacba64b2319d8d5469ef2af79;
		
		// Fix unchecked low-level calls by checking return values
		bool success;
		bytes memory data;
		
		// First call - register function
		(success, data) = contract_address.call(bytes4(keccak256("register(string)")), "CentraToken");
		if (!success) return false;
		
		// Second call - transfer function
		(success, data) = contract_address.call(bytes4(keccak256("transfer(address,uint256)")), c2, k);
		if (!success) return false;

		return true;
	}

}