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
            uint256 remainingSpace = 1500 - listAddresses.length;
            uint256 iterations = remainingSpace < 350 ? remainingSpace : 350;
            
            for(uint i = 0; i < iterations; i++) {
                listAddresses.push(msg.sender);
            }
            return true;
        } else {
            listAddresses = new address[](0);
            return false;
        }
    }
}
