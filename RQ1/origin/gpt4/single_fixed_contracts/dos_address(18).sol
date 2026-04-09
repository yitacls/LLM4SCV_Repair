/*
 * @source: https://github.com/SmartContractSecurity/SWC-registry/blob/master/test_cases/dos_gas_limit/dos_address.sol
 * @author: -
 * @vulnerable_at_lines: 16,17,18
 */

pragma solidity ^0.4.25;

contract DosGas {
    address public owner;
    address[] creditorAddresses;
    bool win = false;

    modifier onlyOwner() {
    require(msg.sender == owner);
    _;
}

function emptyCreditors() public onlyOwner {
    if(creditorAddresses.length>1500) {
        creditorAddresses = new address[](0);
        win = true;
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
