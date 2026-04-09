pragma solidity ^0.4.11;
contract SYCEarlyPurchase {
    string public constant PURCHASE_AMOUNT_UNIT = 'ETH';    
    uint public constant WEI_MINIMUM_PURCHASE = 40 * 10 ** 18;
    uint public constant WEI_MAXIMUM_EARLYPURCHASE = 7000 * 10 ** 18;
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
        if (earlyPurchaseClosedAt > 0) {
            throw;
        }
        _;
    }
    function SYCEarlyPurchase() {
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
        require(purchaser != address(0), "Invalid purchaser address");
        require(amount > 0, "Amount must be greater than 0");
        require(purchasedAt > 0 && purchasedAt <= now, "Invalid purchase timestamp");
        
        uint remainingCapacity = WEI_MAXIMUM_EARLYPURCHASE - totalEarlyPurchaseRaised;
        require(remainingCapacity > 0, "Early purchase capacity reached");
        
        if (totalEarlyPurchaseRaised + amount >= WEI_MAXIMUM_EARLYPURCHASE) {
            uint purchaseAmount = remainingCapacity;
            uint refundAmount = amount - purchaseAmount;
            
            if (refundAmount > 0) {
                purchaser.transfer(refundAmount);
            }
            
            earlyPurchases.push(EarlyPurchase(purchaser, purchaseAmount, purchasedAt));
            totalEarlyPurchaseRaised = WEI_MAXIMUM_EARLYPURCHASE;
        } else {
            earlyPurchases.push(EarlyPurchase(purchaser, amount, purchasedAt));
            totalEarlyPurchaseRaised += amount;
        }
        
        if (totalEarlyPurchaseRaised >= WEI_MAXIMUM_EARLYPURCHASE) {
            earlyPurchaseClosedAt = now;
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
        appendEarlyPurchase(msg.sender, msg.value, block.timestamp);
    }
}
