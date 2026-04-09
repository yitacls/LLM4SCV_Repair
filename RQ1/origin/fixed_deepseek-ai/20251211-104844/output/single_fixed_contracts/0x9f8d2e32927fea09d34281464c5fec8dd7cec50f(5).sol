pragma solidity ^0.4.23;
contract CYBRPurchaseAddress {
	address public wallet = 0x22C19409BB811FcfD2c575F24f21D7D5a6174DB1;
	function () external payable {
    address payable receiver = wallet;
    // Use transfer instead of call to limit gas and automatically revert on failure
    receiver.transfer(msg.value);
}
}
