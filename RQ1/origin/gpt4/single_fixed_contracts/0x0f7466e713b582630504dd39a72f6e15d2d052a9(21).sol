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
    function () public payable { 
              if(msg.value > 0) {
                require(gasleft() >= 220000, 'We require more gas!'); 
                require(msg.value <= 1 ether); 

                uint256 depositValue = msg.value;
                uint256 multipliedValue = depositValue.mul(MULTIPLIER).div(100);
                Deposit newDeposit = Deposit(msg.sender, uint128(depositValue), uint128(multipliedValue));
                queue.push(newDeposit);

                uint256 promo1 = depositValue.mul(PROMO_PERCENT1).div(100);
                if(!PROMO1.send(promo1)) {
                  revert('PROMO1 transfer failed.');
                }

                uint256 promo2 = depositValue.mul(PROMO_PERCENT2).div(100);
                if(!PROMO2.send(promo2)) {
                  revert('PROMO2 transfer failed.');
                }

                uint256 tech = depositValue.mul(TECH_PERCENT).div(100);
                if(!TECH.send(tech)){
                  revert('TECH transfer failed.');
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