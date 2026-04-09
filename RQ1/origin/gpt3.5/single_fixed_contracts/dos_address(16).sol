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
    uint256 length = creditorAddresses.length;
    require(length > 1500, "No creditors to empty");

    // Clear the array in chunks to prevent gas limit issues
    for (uint256 i = 0; i < length; i += 128) {
        uint256 end = i + 128 < length ? i + 128 : length;
        for (uint256 j = i; j < end; j++) {
            delete creditorAddresses[j];
        }
    }

    creditorAddresses.length = 0;  // Reset the array length
    win = true;
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
