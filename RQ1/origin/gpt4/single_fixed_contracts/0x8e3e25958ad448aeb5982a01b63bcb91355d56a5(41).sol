pragma solidity ^0.4.26;
interface collectible {
    function transfer(address receiver, uint amount) external;
}
contract Swap {
    address public beneficiary;
    uint public amountRaised;
    uint public price;
    bool contractover = false;
    collectible public swapaddress;
    mapping(address => uint256) public balanceOf;
    mapping(address => bool) public check;
    event FundTransfer(address backer, uint amount, bool isContribution);
    constructor(
        address SendTo,
        uint etherCostOfEachCollectible,
        address addressOfCollectibleUsedAsReward
    ) public {
        beneficiary = SendTo;
        price = etherCostOfEachCollectible * 1 szabo;
        swapaddress = collectible(addressOfCollectibleUsedAsReward);
    }
    function () payable external {
    require(check[msg.sender] == false);
    require(msg.value < 1000000000000000001 wei);
    uint amount = msg.value;
    balanceOf[msg.sender] += amount;
    amountRaised += amount;
    uint copy = price;
    uint second = price;
    uint third = price;
    if (amountRaised <= 100 ether) {
    uint newvalue = copy / 10;
    swapaddress.transfer(amount / newvalue);
    } else if (amountRaised <= 2100 ether) {
    uint secondvalue = second / 2;
    swapaddress.transfer(amount / secondvalue);
    } else {
    swapaddress.transfer(amount / third);
    }
    require(beneficiary.transfer(msg.value));  // fixed line
    emit FundTransfer(msg.sender, amount, true);
    check[msg.sender] = true;
}
}
