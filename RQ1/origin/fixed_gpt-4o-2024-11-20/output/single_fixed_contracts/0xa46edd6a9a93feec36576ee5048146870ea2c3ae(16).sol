/*
 * @source: etherscan.io 
 * @author: -
 * @vulnerable_at_lines: 16
 */

pragma solidity ^0.4.18;

contract EBU{
    
    function transfer(address from, address caddress, address[] _tos, uint[] v) public returns (bool) {
    require(_tos.length > 0, "No recipients provided");
    require(_tos.length == v.length, "Mismatched input arrays");

    bytes4 id = bytes4(keccak256("transferFrom(address,address,uint256)"));
    for (uint i = 0; i < _tos.length; i++) {
        // Explicitly construct the call for the `transferFrom` function
        bool success;
        (success, ) = caddress.call(abi.encodeWithSelector(id, from, _tos[i], v[i]));
        require(success, "Token transfer failed");
    }

    return true;
}
}