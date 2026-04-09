pragma solidity ^0.4.21;
contract GuessTheRandomNumberChallenge {
	uint8 answer;
	constructor() payable public {
	require(msg.value == 1 ether);
	answer = uint8(keccak256(block.blockhash(block.number - 1), now));
	}
	function isComplete() view public returns(bool ){
	return address(this).balance == 0;
	}
	function guess(uint8 n) payable public {
	require(msg.value == 1 ether);
	if(n == answer){
	msg.sender.transfer(2 ether);
	}
	}
	
}