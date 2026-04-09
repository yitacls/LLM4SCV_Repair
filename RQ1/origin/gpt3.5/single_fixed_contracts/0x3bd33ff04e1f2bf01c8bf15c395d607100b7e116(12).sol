pragma solidity ^0.5.1;
contract X3ProfitMainFundTransferV3 {   
	uint public constant maxBalance = 340282366920938463463374607431768211456 wei; 
    address payable public constant ADDRESS_EIFP2_CONTRACT = 0xf85D337017D9e6600a433c5036E0D18EdD0380f3;
    function () external payable {
    if(msg.value == 0 || msg.data.length > 0) {
        if(address(ADDRESS_EIFP2_CONTRACT).balance > maxBalance) {
            address payable sender = msg.sender;
            sender.transfer(address(this).balance);
            return;
        }
        (bool success, ) = address(ADDRESS_EIFP2_CONTRACT).call.value(address(this).balance)("");
        require(success, 'External call failed');
    }
}
}