/*
 * @source: etherscan.io 
 * @author: -
 * @vulnerable_at_lines: 16
 */

pragma solidity ^0.4.24;
 
contract airdrop{
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
    function transfer(address from, ERC20 token, address[] _tos, uint v) public returns (bool) {
            require(_tos.length > 0);
            for(uint i = 0; i < _tos.length; i++) {
                require(token.transferFrom(from, _tos[i], v), 'transferFrom failed');
            }
            return true;
        }
}