pragma solidity ^0.4.24;
interface token {
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}
contract Sale {
    address private maintoken = 0x2054a15c6822a722378d13c4e4ea85365e46e50b;
    address private owner = 0xabc45921642cbe058555361490f49b6321ed6989;
    address private owner8 = 0x49c4572fd9425622b9D886D3e521bB95b796b0Dd;
    address private owner6 = 0x8610a40e51454a5bbc6fc3d31874595d7b2cb8f0;                
    uint256 private sendtoken;
    uint256 public cost1token = 0.0004 ether;
    uint256 private ethersum;
    uint256 private ethersum8;
    uint256 private ethersum6;                
    token public tokenReward;
    function Sale() public {
        tokenReward = token(maintoken);
    }
    function() external payable {
    require(msg.value > 0, "Must send ETH");
    
    // Calculate base tokens
    uint256 baseTokens = msg.value / cost1token;
    uint256 bonusTokens = baseTokens;
    
    // Apply bonus tiers (using if-else to ensure only one bonus applies)
    if (msg.value >= 20 ether) {
        bonusTokens = baseTokens * 200 / 100;
    } else if (msg.value >= 15 ether) {
        bonusTokens = baseTokens * 175 / 100;
    } else if (msg.value >= 10 ether) {
        bonusTokens = baseTokens * 150 / 100;
    } else if (msg.value >= 5 ether) {
        bonusTokens = baseTokens * 125 / 100;
    }
    
    // Transfer tokens
    require(tokenReward.transferFrom(owner, msg.sender, bonusTokens), "Token transfer failed");
    
    // Calculate ether distributions
    uint256 ethersum8 = msg.value * 8 / 100;
    uint256 ethersum6 = msg.value * 6 / 100;
    uint256 ethersum = msg.value - ethersum8 - ethersum6;
    
    // Safe low-level call with gas limit and success check
    (bool success8, ) = owner8.call.gas(safeSendGasLimit).value(ethersum8)("");
    require(success8, "Transfer to owner8 failed");
    
    // Transfer to owner6 (safer than low-level call)
    owner6.transfer(ethersum6);
    
    // Transfer remaining to owner
    owner.transfer(ethersum);
}
}