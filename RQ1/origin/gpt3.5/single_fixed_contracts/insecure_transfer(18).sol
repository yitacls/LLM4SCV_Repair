/*
 * @source: https://consensys.github.io/smart-contract-best-practices/known_attacks/#front-running-aka-transaction-ordering-dependence
 * @author: consensys
 * @vulnerable_at_lines: 18
 */

pragma solidity ^0.4.0;

contract IntegerOverflowAdd {
    mapping (address => uint256) public balanceOf;

    // INSECURE
    function transfer(address _to, uint256 _value) public {
    require(balanceOf[msg.sender] >= _value);
    require(balanceOf[_to] + _value >= balanceOf[_to]); // Check for overflow
    balanceOf[msg.sender] -= _value;
    balanceOf[_to] += _value;
}

}
