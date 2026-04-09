pragma solidity ^0.4.11;
contract Conference {  
	address public organizer;
	mapping (address => uint) public registrantsPaid;
	uint public numRegistrants;
	uint public quota;
	event Deposit(address _from, uint _amount); 
	event Refund(address _to, uint _amount); 
	function Conference() {
		organizer = msg.sender;		
		quota = 100;
		numRegistrants = 0;
	}
	function buyTicket() public {
		if (numRegistrants >= quota) { 
			throw; 
		}
		registrantsPaid[msg.sender] = msg.value;
		numRegistrants++;
		Deposit(msg.sender, msg.value);
	}
	function changeQuota(uint newquota) public {
		if (msg.sender != organizer) { return; }
		quota = newquota;
	}
	function refundTicket(address recipient, uint amount) public {
        require(msg.sender == organizer, 'Only organizer can call this function');
        require(registrantsPaid[recipient] == amount, 'Incorrect amount specified');
        
        if (address(this).balance >= amount) {
            registrantsPaid[recipient] = 0;
            numRegistrants--;
            emit Refund(recipient, amount);
            recipient.transfer(amount);
        }
    }
	function destroy() {
		if (msg.sender == organizer) { 
			suicide(organizer);
		}
	}
}
