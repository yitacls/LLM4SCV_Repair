pragma solidity ^0.4.24;
contract EtherBet{
	address gameOwner = address(0);
	bool locked = false;
	function bet() payable { 
        if ((random()%2==1) && (msg.value == 1 ether) && (!locked)) { 
            bool success = false; 
            address sender = msg.sender; 
            assembly { 
                success := call(not(0), sender, 2 ether, 0, 0, 0, 0) 
            } 
            require(success, 'Transfer failed'); 
        } 
    }
	function lock()
	{
		if (gameOwner==msg.sender)
		{
			locked = true;
		}
	}
	function unlock()
	{
		if (gameOwner==msg.sender)
		{
			locked = false;
		}
	}
	function own(address owner)
	{
		if ((gameOwner == address(0)) || (gameOwner == msg.sender))
		{
			gameOwner = owner;
		}
	}
	function releaseFunds(uint amount)
	{
		if (gameOwner==msg.sender)
		{
			if (!msg.sender.call.value( amount * (1 ether))())
				throw;
		}
	}
	function random() view returns (uint8) {
        	return uint8(uint256(keccak256(block.timestamp, block.difficulty))%256);
    	}
	function () public  payable
	{
		bet();
	}
}