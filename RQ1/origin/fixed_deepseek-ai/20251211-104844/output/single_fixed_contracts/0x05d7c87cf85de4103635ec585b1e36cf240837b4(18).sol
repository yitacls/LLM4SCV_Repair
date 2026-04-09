pragma solidity ^0.4.25;
contract MMMultiplierX {
    uint constant public MULTIPLIER = 200;
    uint totalIn;
    uint public maxDep = (100000000000000000000+totalIn)/100;
    struct Deposit {
        address depositor; 
        uint128 deposit;   
        uint128 expect;    
    }
    Deposit[] private queue;  
    uint  currentReceiverIndex = 0; 
    function () public payable {
        if(msg.value > 0){
            require(gasleft() >= 220000, "We require more gas!");
            require(msg.value <= maxDep);
            
            totalIn += msg.value;
            
            // Safe multiplication to prevent overflow
            uint256 multipliedValue = msg.value;
            multipliedValue = multipliedValue * MULTIPLIER;
            require(multipliedValue / MULTIPLIER == msg.value, "Multiplication overflow");
            
            // Safe division and casting
            uint128 reward = uint128(multipliedValue / 100);
            require(uint256(reward) == multipliedValue / 100, "Casting overflow");
            
            uint128 depositValue = uint128(msg.value);
            require(uint256(depositValue) == msg.value, "Casting overflow");
            
            queue.push(Deposit(msg.sender, depositValue, reward));
            pay();
        }
    }
    function pay() private {
        uint128 money = uint128(address(this).balance);
        for(uint i=0; i<queue.length; i++){
            uint idx = currentReceiverIndex + i;  
            Deposit storage dep = queue[idx]; 
            if(money >= dep.expect){  
                dep.depositor.send(dep.expect); 
                money -= dep.expect;            
                delete queue[idx];
            }else{
                dep.depositor.send(money); 
                dep.expect -= money;       
                break;                     
            }
            if(gasleft() <= 50000)         
                break;                     
        }
        currentReceiverIndex += i; 
    }
}