/*
 * @source: https://github.com/SmartContractSecurity/SWC-registry/blob/master/test_cases/dos_gas_limit/dos_simple.sol
 * @author: -
 * @vulnerable_at_lines: 17,18
 */


pragma solidity ^0.4.25;

contract DosOneFunc {

    address[] listAddresses;

    function ifillArray() public returns (bool) {
    require(gasleft() > 100000, "Insufficient gas");
    
    if (listAddresses.length < 1500) {
        uint256 remainingCapacity = 1500 - listAddresses.length;
        uint256 maxIterations = remainingCapacity < 350 ? remainingCapacity : 350;
        
        for (uint256 i = 0; i < maxIterations; i++) {
            listAddresses.push(msg.sender);
            // Check gas remaining after each push to prevent running out of gas
            if (gasleft() < 50000) {
                break;
            }
        }
        return true;
    } else {
        listAddresses = new address[](0);
        return false;
    }
}
}
