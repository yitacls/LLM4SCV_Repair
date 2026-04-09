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
    for(uint x; x < refundAddresses.length; x++) {
        address payable recipient = payable(refundAddresses[x]);
        uint refundAmount = refunds[recipient];
        refunds[recipient] = 0; // Secure: zero out refund amount before transfer
        if (refundAmount > 0) {
            (bool success, ) = recipient.call{value: refundAmount}('');
            require(success, 'Failed to send refund');
        }
    }
}

}
