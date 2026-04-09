/*
 * @source: https://github.com/seresistvanandras/EthBench/blob/master/Benchmark/Simple/mishandled.sol 
 * @author: -
 * @vulnerable_at_lines: 14
 */

pragma solidity ^0.4.0;
contract SendBack {
    mapping (address => uint) userBalances;
    function withdrawBalance() {  
	          uint amountToWithdraw = userBalances[msg.sender];
	          userBalances[msg.sender] = 0;
	          msg.sender.transfer(amountToWithdraw);
	        }
}