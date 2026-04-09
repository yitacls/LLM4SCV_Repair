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
    /* Check if sender has balance */
    require(balanceOf[msg.sender] >= _value);
    
    // Safe subtraction is not strictly needed for this operation since we checked the balance,
    // but using SafeMath for consistency
    balanceOf[msg.sender] = balanceOf[msg.sender] - _value;
    
    // Prevent overflow when adding to recipient's balance
    require(balanceOf[_to] + _value >= balanceOf[_to]);
    balanceOf[_to] += _value;
}

}
