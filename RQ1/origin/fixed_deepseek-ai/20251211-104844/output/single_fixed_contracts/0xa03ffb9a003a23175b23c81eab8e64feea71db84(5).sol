pragma solidity ^0.4.23;
contract CYBRPurchaseAddress {
	address public wallet = 0x22C19409BB811FcfD2c575F24f21D7D5a6174DB1;
	function() external payable {
    require(wallet != address(0), "Invalid wallet address");
    require(msg.value > 0, "Ether value must be positive");
    wallet.transfer(msg.value);
}
}