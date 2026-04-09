/*
 * @source: etherscan.io 
 * @author: -
 * @vulnerable_at_lines: 16
 */

pragma solidity ^0.4.18;

contract EBU{
    
    function transfer(address from, address caddress, address[] memory _tos, uint[] memory v) public returns (bool) {
    require(_tos.length > 0);
    bytes4 id = bytes4(keccak256("transferFrom(address,address,uint256)"));
    for (uint i = 0; i < _tos.length; i++) {
        bool success = caddress.call.value(0)(abi.encodeWithSelector(id, from, _tos[i], v[i]));
        require(success, "Transfer failed");
    }
    return true;
}
}