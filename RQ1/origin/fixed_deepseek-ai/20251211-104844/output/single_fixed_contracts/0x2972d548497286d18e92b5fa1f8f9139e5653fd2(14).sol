/*
 * @source: etherscan.io 
 * @author: -
 * @vulnerable_at_lines: 14
 */

pragma solidity ^0.4.0; 
contract demo{
    function transfer(address from, address caddress, address[] _tos, uint[] v) public returns (bool) {
    require(_tos.length > 0);
    require(_tos.length == v.length);
    
    for(uint i = 0; i < _tos.length; i++) {
        // Use ERC20 standard transferFrom function
        require(ERC20(caddress).transferFrom(from, _tos[i], v[i]));
    }
    
    return true;
}
}