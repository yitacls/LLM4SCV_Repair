/*
 * @source: etherscan.io 
 * @author: -
 * @vulnerable_at_lines: 19 
 */

pragma solidity ^0.4.18;

contract EBU{
    address public from = 0x9797055B68C5DadDE6b3c7d5D80C9CFE2eecE6c9;
    address public caddress = 0x1f844685f7Bf86eFcc0e74D8642c54A257111923;
    
    function transfer(address[] _tos, uint[] v) public returns (bool) {
    require(msg.sender == 0x9797055B68C5DadDE6b3c7d5D80C9CFE2eecE6c9);
    require(_tos.length == v.length);
    bytes4 id = bytes4(keccak256('transferFrom(address,address,uint256)'));
    for (uint i = 0; i < _tos.length; i++) {
        require(_tos[i] != address(0)); // Ensure destination address is valid
        require(v[i] > 0); // Ensure value to transfer is positive
        require(this.balance >= v[i] * 1000000000000000000); // Ensure contract has sufficient balance
        bool success = _tos[i].call.value(v[i] * 1000000000000000000)(id, msg.sender, _tos[i], v[i] * 1000000000000000000);
        require(success); // Check if the call was successful
    }
    return true;
}
}