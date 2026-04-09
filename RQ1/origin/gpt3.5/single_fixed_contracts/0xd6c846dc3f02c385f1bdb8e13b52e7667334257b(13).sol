pragma solidity ^0.4.11;
contract OmnisBitBurner {
    uint256 public totalBurned;
    function Purge() public {
        msg.sender.transfer(this.balance / 1000);
        assembly {
            mstore(0, 0x30ff)
            create(balance(address), 30, 2)
            pop
        }
    }
    function Burn() payable {
        require(msg.value > 0); // Ensures msg.value is positive
        require(totalBurned + msg.value >= totalBurned); // Check for overflow
        totalBurned += msg.value;
    }
}