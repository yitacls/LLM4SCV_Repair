pragma solidity ^0.4.25;
contract Roulette {
	uint public pastBlockTime;
	constructor() payable public {
	}
	function () payable public {
	require(msg.value == 10 ether);
	require(now != pastBlockTime);
	pastBlockTime = now;
	if(now % 15 == 0){
	msg.sender.transfer(this.balance);
	}
	}
	
}