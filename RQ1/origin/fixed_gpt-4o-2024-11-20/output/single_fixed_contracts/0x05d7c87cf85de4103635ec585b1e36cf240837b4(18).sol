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
    require(gasleft() >= 220000, "We require more gas!");
    require(msg.value > 0, "No deposit provided!");
    require(msg.value <= maxDep, "Deposit exceeds maximum limit!");

    // Ensure addition does not overflow
    require(totalIn + msg.value >= totalIn, "Overflow detected in totalIn calculation!");
    totalIn += msg.value;

    // Calculate reward safely
    uint128 reward = uint128(msg.value) * uint128(MULTIPLIER) / 100;
    require(reward / uint128(MULTIPLIER) == uint128(msg.value) / 100, "Overflow detected in reward calculation!");

    queue.push(Deposit(msg.sender, uint128(msg.value), reward));

    pay();
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