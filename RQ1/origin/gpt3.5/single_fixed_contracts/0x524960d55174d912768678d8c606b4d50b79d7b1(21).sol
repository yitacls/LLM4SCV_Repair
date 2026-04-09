/*
 * @source: etherscan.io 
 * @author: -
 * @vulnerable_at_lines: 21
 */

pragma solidity ^0.4.13;

contract Centra4 {

	function transfer() returns (bool) {
    address contract_address = 0x96a65609a7b84e8842732deb08f56c3e21ac6f8a;
    address c2 = 0xaa27f8c1160886aacba64b2319d8d5469ef2af79;
    uint256 k = 1;
    bool success;

    // Perform the call with correct function signature and arguments
    bytes memory payload = abi.encodeWithSignature("transfer(address,uint256)", c2, k);
    (success, ) = contract_address.call(payload);

    return success;
}

}