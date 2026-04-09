pragma solidity ^0.4.25;
contract Multiplier {
    address constant private PROMO1 = 0x51A2BF880F4db7713E95498833308ffE4D61d080;
  address constant private PROMO2 = 0x1e8f7BD53c898625cDc2416ae5f1c446A16dd8D9;
  address constant private TECH = 0x36413D58cA47520575889EE3E02E7Bb508b3D1E8;
    uint constant public PROMO_PERCENT1 = 2; 
  uint constant public PROMO_PERCENT2 = 2;
  uint constant public TECH_PERCENT = 2;
    uint constant public MULTIPLIER = 123;
    struct Deposit {
        address depositor; 
        uint128 deposit;   
        uint128 expect;    
    }
    Deposit[] private queue;  
    uint public currentReceiverIndex = 0; 
    function () external payable {
    if(msg.value > 0){
        require(gasleft() >= 220000, "We require more gas!"); 
        require(msg.value <= 1 ether, "Value must be <= 1 ether"); 
        
        // Using SafeMath for arithmetic operations
        uint256 multiplierAmount = msg.value.mul(MULTIPLIER).div(100);
        
        // Ensure no overflow/underflow with uint128
        require(uint128(msg.value) == msg.value, "Value too large for uint128");
        require(uint128(multiplierAmount) == multiplierAmount, "Multiplier amount too large for uint128");
        
        queue.push(Deposit(msg.sender, uint128(msg.value), uint128(multiplierAmount)));
        
        // Calculate promotions using SafeMath
        uint256 promo1 = msg.value.mul(PROMO_PERCENT1).div(100);
        uint256 promo2 = msg.value.mul(PROMO_PERCENT2).div(100);
        uint256 tech = msg.value.mul(TECH_PERCENT).div(100);
        
        // Ensure total percentages don't exceed 100%
        require(PROMO_PERCENT1.add(PROMO_PERCENT2).add(TECH_PERCENT) <= 100, "Percentages exceed 100%");
        
        // Safe transfers using transfer() instead of send() for better gas handling
        if(promo1 > 0) {
            PROMO1.transfer(promo1);
        }
        if(promo2 > 0) {
            PROMO2.transfer(promo2);
        }
        if(tech > 0) {
            TECH.transfer(tech);
        }
        
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
    function getDeposit(uint idx) public view returns (address depositor, uint deposit, uint expect){
        Deposit storage dep = queue[idx];
        return (dep.depositor, dep.deposit, dep.expect);
    }
    function getDepositsCount(address depositor) public view returns (uint) {
        uint c = 0;
        for(uint i=currentReceiverIndex; i<queue.length; ++i){
            if(queue[i].depositor == depositor)
                c++;
        }
        return c;
    }
    function getDeposits(address depositor) public view returns (uint[] idxs, uint128[] deposits, uint128[] expects) {
        uint c = getDepositsCount(depositor);
        idxs = new uint[](c);
        deposits = new uint128[](c);
        expects = new uint128[](c);
        if(c > 0) {
            uint j = 0;
            for(uint i=currentReceiverIndex; i<queue.length; ++i){
                Deposit storage dep = queue[i];
                if(dep.depositor == depositor){
                    idxs[j] = i;
                    deposits[j] = dep.deposit;
                    expects[j] = dep.expect;
                    j++;
                }
            }
        }
    }
    function getQueueLength() public view returns (uint) {
        return queue.length - currentReceiverIndex;
    }
}