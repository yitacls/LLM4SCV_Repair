/*
 * @source: https://github.com/SmartContractSecurity/SWC-registry/blob/master/test_cases/dos_gas_limit/dos_simple.sol
 * @author: -
 * @vulnerable_at_lines: 17,18
 */


pragma solidity ^0.4.25;

contract DosOneFunc {

    address[] listAddresses;

    function ifillArray() public returns (bool) {
    if (listAddresses.length < TOTAL_CAPACITY) {
        uint256 remainingCapacity = TOTAL_CAPACITY - listAddresses.length;
        uint256 batchSize = remainingCapacity < MAX_BATCH_SIZE ? remainingCapacity : MAX_BATCH_SIZE;
        
        require(batchSize > 0, "No capacity available");
        
        for (uint256 i = 0; i < batchSize; i++) {
            listAddresses.push(msg.sender);
        }
        return true;
    } else {
        listAddresses = new address[](0);
        return false;
    }
}
}
