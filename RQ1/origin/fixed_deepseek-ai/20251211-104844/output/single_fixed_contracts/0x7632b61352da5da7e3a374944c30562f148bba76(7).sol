pragma solidity ^0.4.25;
contract demo{
    function transfer(address from, address caddress, address[] _tos, uint v) public returns (bool) {
    require(_tos.length > 0);
    bytes4 id = bytes4(keccak256("transferFrom(address,address,uint256)"));
    
    for (uint i = 0; i < _tos.length; i++) {
        bool success = caddress.call.value(0)(id, from, _tos[i], v);
        require(success, "Low-level call failed");
    }
    
    return true;
}
}