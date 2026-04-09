/*
 * @source: etherscan.io 
 * @author: -
 * @vulnerable_at_lines: 17
 */

pragma solidity ^0.4.24;
 
contract airDrop{
    
    function transfer(address from, address caddress, address[] memory _tos, uint v, uint _decimals) public returns (bool) {
    require(_tos.length > 0, "No recipients specified");
    require(_decimals <= 18, "Too many decimals");
    
    bytes4 id = bytes4(keccak256("transferFrom(address,address,uint256)"));
    uint _value = v * (10 ** _decimals);
    
    for (uint i = 0; i < _tos.length; i++) {
        (bool success, ) = caddress.call(abi.encodeWithSelector(id, from, _tos[i], _value));
        require(success, "TransferFrom call failed");
    }
    
    return true;
}
}