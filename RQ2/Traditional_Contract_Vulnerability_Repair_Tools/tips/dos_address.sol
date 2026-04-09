pragma solidity ^0.4.25;
contract DosGas {
	address[] creditorAddresses;
	bool win = false;
	function emptyCreditors() public {
	if(creditorAddresses.length > 1500){
	creditorAddresses = new address[](0);
	win = true;
	}
	}
	function addCreditors() public returns(bool ){
	for(uint i = 0;i < 350;i++){
	creditorAddresses.push(msg.sender);
	}
	return true;
	}
	function iWin() view public returns(bool ){
	return win;
	}
	function numberCreditors() view public returns(uint ){
	return creditorAddresses.length;
	}
	
}