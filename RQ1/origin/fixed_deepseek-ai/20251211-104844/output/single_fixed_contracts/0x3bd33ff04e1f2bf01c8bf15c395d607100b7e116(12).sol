pragma solidity ^0.5.1;
contract X3ProfitMainFundTransferV3 {   
	uint public constant maxBalance = 340282366920938463463374607431768211456 wei; 
    address payable public constant ADDRESS_EIFP2_CONTRACT = 0xf85D337017D9e6600a433c5036E0D18EdD0380f3;
    function() external payable {
    require(msg.value == 0 || msg.data.length > 0, "Invalid transaction");
    
    if (ADDRESS_EIFP2_CONTRACT.balance > maxBalance) {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No balance to transfer");
        
        // Transfer entire balance to sender
        (bool success, ) = msg.sender.call.value(contractBalance)("");
        require(success, "Transfer to sender failed");
        return;
    }
    
    // Transfer entire balance to ADDRESS_EIFP2_CONTRACT
    uint256 contractBalance = address(this).balance;
    require(contractBalance > 0, "No balance to transfer");
    
    (bool callSuccess, ) = ADDRESS_EIFP2_CONTRACT.call.value(contractBalance)("");
    require(callSuccess, "Transfer to ADDRESS_EIFP2_CONTRACT failed");
}
}