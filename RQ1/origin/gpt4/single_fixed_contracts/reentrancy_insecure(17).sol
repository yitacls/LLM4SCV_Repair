/*
 * @source: https://consensys.github.io/smart-contract-best-practices/known_attacks/
 * @author: consensys
 * @vulnerable_at_lines: 17
 */

pragma solidity ^0.4.0;

contract Reentrancy_insecure {

    // INSECURE
    mapping (address => uint) private userBalances;

    function withdrawBalance() public {
	uint amountToWithdraw = userBalances[msg.sender];
	userBalances[msg.sender] = 0;
	(bool success, ) = msg.sender.call.value(amountToWithdraw)("");
	require(success);
}
}
