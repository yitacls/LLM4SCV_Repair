/*
 * @source: https://consensys.github.io/smart-contract-best-practices/known_attacks/#dos-with-unexpected-revert
 * @author: ConsenSys Diligence
* @vulnerable_at_lines: 24
 * Modified by Bernhard Mueller
 */

pragma solidity 0.4.24;

contract Refunder {
    
address[] private refundAddresses;
mapping (address => uint) public refunds;

    constructor() {
        refundAddresses.push(0x79B483371E87d664cd39491b5F06250165e4b184);
        refundAddresses.push(0x79B483371E87d664cd39491b5F06250165e4b185);
    }

    // bad
    function refundAll() public {
        uint length = refundAddresses.length;
        for(uint x = 0; x < length; x++) {
            address recipient = refundAddresses[x];
            uint amount = refunds[recipient];
            
            // Reset the refund amount to prevent reentrancy
            refunds[recipient] = 0;
            
            // Use transfer instead of send for better error handling
            recipient.transfer(amount);
            
            // Remove the processed address
            refundAddresses[x] = refundAddresses[refundAddresses.length - 1];
            refundAddresses.length--;
            x--; // Adjust index since we removed an element
            length--;
        }
    }

}
