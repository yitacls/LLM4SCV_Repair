/*
 * @source: https://github.com/SmartContractSecurity/SWC-registry/blob/master/test_cases/dos_gas_limit/dos_simple.sol
 * @author: -
 * @vulnerable_at_lines: 17,18
 */


pragma solidity ^0.4.25;

contract DosOneFunc {

    address[] listAddresses;

    function ifillArray() public returns (bool) {
    uint gasToUse = gasleft() - 50000; // Adjust gas limit to ensure safe execution
    uint count = 0;
    while (gasToUse >= 10000 && listAddresses.length < 1500 && count < 350) {
        listAddresses.push(msg.sender);
        gasToUse -= 10000;
        count++;
    }
    return count > 0;
}
}
