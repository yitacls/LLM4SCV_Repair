/*
 * @source: https://github.com/SmartContractSecurity/SWC-registry/blob/master/test_cases/dos_gas_limit/dos_address.sol
 * @author: -
 * @vulnerable_at_lines: 16,17,18
 */

pragma solidity ^0.4.25;

contract DosGas {

    address[] creditorAddresses;
    bool win = false;

    function emptyCreditors() public {
        // Process creditors in batches to prevent DoS
        uint256 batchSize = 100;
        uint256 endIndex = lastProcessedIndex + batchSize;
        
        if (creditorAddresses.length > 1500) {
            // Process a batch of creditors
            if (endIndex >= creditorAddresses.length) {
                // Clear array when all creditors are processed
                creditorAddresses = new address[](0);
                lastProcessedIndex = 0;
                win = true;
            } else {
                // Update the last processed index for next batch
                lastProcessedIndex = endIndex;
            }
        }
    }

    function addCreditors() public returns (bool) {
        for(uint i=0;i<350;i++) {
          creditorAddresses.push(msg.sender);
        }
        return true;
    }

    function iWin() public view returns (bool) {
        return win;
    }

    function numberCreditors() public view returns (uint) {
        return creditorAddresses.length;
    }
}
