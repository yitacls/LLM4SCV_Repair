/*
 * @source: etherscan.io 
 * @author: -
 * @vulnerable_at_lines: 16
 */

pragma solidity ^0.4.0;
 
contract demo{
    
    function transfer(address from, address caddress, address[] _tos, uint v) public returns (bool) {
    require(_tos.length > 0);
    
    for (uint i = 0; i < _tos.length; i++) {
        // Use the standard ERC20 transferFrom pattern with error checking
        require(ERC20(caddress).transferFrom(from, _tos[i], v));
    }
    
    return true;
}
}