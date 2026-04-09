/*
 * @source: https://github.com/SmartContractSecurity/SWC-registry/blob/master/test_cases/dos_gas_limit/dos_simple.sol
 * @author: -
 * @vulnerable_at_lines: 17,18
 */


pragma solidity ^0.4.25;

contract DosOneFunc {

    address[] listAddresses;

    function ifillArray() public returns (bool){
        if(listAddresses.length < 1500) {
            uint gasStart = msg.gas;
            uint iterations = 0;
            // Limit iterations to prevent gas exhaustion
            while(iterations < 50 && listAddresses.length < 1500) {
                // Check if we're running low on gas
                if(gasStart - (gasStart - msg.gas) > 50000) break;
                listAddresses.push(msg.sender);
                iterations++;
            }
            return true;
        } else {
            listAddresses = new address[](0);
            return false;
        }
    }
}
