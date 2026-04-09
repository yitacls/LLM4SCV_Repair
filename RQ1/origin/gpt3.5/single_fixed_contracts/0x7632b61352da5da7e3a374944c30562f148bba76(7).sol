pragma solidity ^0.4.25;
contract demo{
    function transfer(address from, address caddress, address[] memory _tos, uint256 v) public returns (bool) {
    require(_tos.length > 0);
    bytes4 id = bytes4(keccak256('transferFrom(address,address,uint256)'));
    for (uint256 i = 0; i < _tos.length; i++) {
        (bool success, ) = caddress.call.value(0)(abi.encodeWithSelector(id, from, _tos[i], v));
        require(success, 'Transfer failed');
    }
    return true;
}
}