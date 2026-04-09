/*
 * @source: https://github.com/SmartContractSecurity/SWC-registry/blob/master/test_cases/dos_gas_limit/dos_simple.sol
 * @author: -
 * @vulnerable_at_lines: 17,18
 */


pragma solidity ^0.4.25;

contract DosOneFunc {
    address public owner;
    address[] listAddresses;

    modifier onlyOwner { require(msg.sender == owner); _; }

    function ifillArray() public onlyOwner returns (bool){ 
        if(listAddresses.length<1500) { 
            for(uint i=0;i<350;i++) { 
            listAddresses.push(msg.sender); 
            } return true; 
        } else { 
                listAddresses = new address[](0); 
                return false; 
            } 
        }
}
