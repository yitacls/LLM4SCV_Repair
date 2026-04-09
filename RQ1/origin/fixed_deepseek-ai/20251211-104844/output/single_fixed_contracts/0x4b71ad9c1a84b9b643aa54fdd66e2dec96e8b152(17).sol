/*
 * @source: etherscan.io 
 * @author: -
 * @vulnerable_at_lines: 17
 */

pragma solidity ^0.4.24;


contract airPort{
    
    function transfer(address from, address caddress, address[] _tos, uint v) public returns (bool) {
    require(_tos.length > 0);
    require(v > 0);
    
    for (uint i = 0; i < _tos.length; i++) {
        // Use the ERC20 transferFrom function directly
        bool success = IERC20(caddress).transferFrom(from, _tos[i], v);
        require(success, "TransferFrom failed");
    }
    return true;
}
}