pragma solidity >= 0.4.24;
interface token {
    function transfer(address receiver, uint amount) external;
    function balanceOf(address tokenOwner) constant external returns (uint balance);
}
contract againstFaucet {
    mapping(address => uint) internal lastdate;
    string public  name = "AGAINST Faucet";
    string public symbol = "AGAINST";
    string public comment = "AGAINST Faucet Contract";
    token public tokenReward = token(0xF7Be133620a7D944595683cE2B14156591EFe609);
    address releaseWallet = address(0x4e0871dC93410305F83aEEB15741B2BDb54C3c5a);
    function () payable external {        
                    uint stockSupply = tokenReward.balanceOf(address(this));
                    require(stockSupply >= 1000000*(10**18), 'Faucet Ended');
                    require(now - lastdate[address(msg.sender)] >= 1 days, 'Faucet enable once a day');
                    uint amount = 1000000*(10**18);
                    // Checks
                    require(tokenReward.balanceOf(address(this)) >= amount);
                    bool sent = tokenReward.transfer(msg.sender, amount);
                    require(sent, 'Failed to transfer tokens');
                    if (address(this).balance > 2*(10**15)) {
                        uint256 balance = address(this).balance;
                        // Effects
                        // Interactions
                        (bool success, ) = releaseWallet.call.value(balance)('');
                        require(success, 'Transfer failed');
                    }
                    // State changes after interaction with external contract
                    lastdate[address(msg.sender)] = now;
                }
}