pragma solidity ^0.4.25;
contract SYC2ndEarlyPurchase {
    string public constant PURCHASE_AMOUNT_UNIT = 'ETH';    
    uint public constant WEI_MINIMUM_PURCHASE = 10 * 10 ** 18;
    uint public constant WEI_MAXIMUM_EARLYPURCHASE = 7000 * 10 ** 18;
    uint public constant STARTING_TIME = 1504526400;
    uint public constant ENDING_TIME = 1504785599;
    address public owner;
    EarlyPurchase[] public earlyPurchases;
    uint public earlyPurchaseClosedAt;
    uint public totalEarlyPurchaseRaised;
    address public sycCrowdsale;
    struct EarlyPurchase {
        address purchaser;
        uint amount;        
        uint purchasedAt;   
    }
    modifier onlyOwner() {
        if (msg.sender != owner) {
            throw;
        }
        _;
    }
    modifier onlyEarlyPurchaseTerm() {
        if (earlyPurchaseClosedAt > 0 || now < STARTING_TIME || now > ENDING_TIME) {
            throw;
        }
        _;
    }
    function SYC2ndEarlyPurchase() {
        owner = msg.sender;
    }
    function purchasedAmountBy(address purchaser)
        external
        constant
        returns (uint amount)
    {
        for (uint i; i < earlyPurchases.length; i++) {
            if (earlyPurchases[i].purchaser == purchaser) {
                amount += earlyPurchases[i].amount;
            }
        }
    }
    function setup(address _sycCrowdsale)
        external
        onlyOwner
        returns (bool)
    {
        if (address(_sycCrowdsale) == 0) {
            sycCrowdsale = _sycCrowdsale;
            return true;
        }
        return false;
    }
    function numberOfEarlyPurchases()
        external
        constant
        returns (uint)
    {
        return earlyPurchases.length;
    }
    function appendEarlyPurchase(address purchaser, uint amount, uint purchasedAt)
        internal
        onlyEarlyPurchaseTerm
        returns (bool)
    {
        if (purchasedAt == 0 || purchasedAt > block.timestamp) {
            revert("Invalid purchase time");
        }
        
        if(totalEarlyPurchaseRaised + amount >= WEI_MAXIMUM_EARLYPURCHASE){
            uint refundAmount = totalEarlyPurchaseRaised + amount - WEI_MAXIMUM_EARLYPURCHASE;
            uint purchaseAmount = WEI_MAXIMUM_EARLYPURCHASE - totalEarlyPurchaseRaised;
            
            if (refundAmount > 0) {
                purchaser.transfer(refundAmount);
            }
            
            earlyPurchases.push(EarlyPurchase(purchaser, purchaseAmount, purchasedAt));
            totalEarlyPurchaseRaised += purchaseAmount;
        }
        else{
            earlyPurchases.push(EarlyPurchase(purchaser, amount, purchasedAt));
            totalEarlyPurchaseRaised += amount;
        }
        
        if(totalEarlyPurchaseRaised >= WEI_MAXIMUM_EARLYPURCHASE || block.timestamp >= ENDING_TIME){
            earlyPurchaseClosedAt = block.timestamp;
        }
        
        return true;
    }
    function closeEarlyPurchase()
        onlyOwner
        returns (bool)
    {
        earlyPurchaseClosedAt = now;
    }
    function withdraw(uint withdrawalAmount) onlyOwner {
          if(!owner.send(withdrawalAmount)) throw;  
    }
    function withdrawAll() onlyOwner {
          if(!owner.send(this.balance)) throw;  
    }
    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
    function () payable{
        require(msg.value >= WEI_MINIMUM_PURCHASE);
        appendEarlyPurchase(msg.sender, msg.value, now);
    }
}