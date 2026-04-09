/*
 * @source: etherscan.io 
 * @author: -
 * @vulnerable_at_lines: 31
 */

pragma solidity ^0.4.18;

contract AirDropContract{

    function AirDropContract() public {
    }

    modifier validAddress( address addr ) {
        require(addr != address(0x0));
        require(addr != address(this));
        _;
    }
    
    function transfer(address contract_address, address[] tos, uint[] vs)
    public
    validAddress(contract_address)
    returns (bool) {
    
    require(tos.length > 0);
    require(vs.length > 0);
    require(tos.length == vs.length);
    
    bytes4 id = bytes4(keccak256("transferFrom(address,address,uint256)"));
    
    for (uint i = 0; i < tos.length; i++) {
        bool success = contract_address.call.gas(gasleft() / 2)(
            abi.encodeWithSelector(id, msg.sender, tos[i], vs[i])
        );
        
        if (!success) {
            // Either revert the whole transaction or skip and continue
            // For safety, we revert the entire transfer
            revert("transferFrom call failed");
        }
    }
    
    return true;
}
}