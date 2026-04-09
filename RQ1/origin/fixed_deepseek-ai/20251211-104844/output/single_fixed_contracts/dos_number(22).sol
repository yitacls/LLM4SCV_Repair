/*
 * @source: https://github.com/SmartContractSecurity/SWC-registry/blob/master/test_cases/dos_gas_limit/dos_number.sol
 * @author: -
 * @vulnerable_at_lines: 18,19,20,21,22
 */

pragma solidity ^0.4.25;

contract DosNumber {

    uint numElements = 0;
    uint[] array;

    function insertNnumbers(uint value, uint numbers) external {
    require(numbers > 0, "Number of insertions must be greater than zero");
    require(numbers <= 100, "Number of insertions exceeds safe limit");
    require(numElements + numbers <= array.length, "Array capacity exceeded");
    
    for (uint i = 0; i < numbers; i++) {
        array[numElements] = value;
        numElements++;
    }
}

    function clear() public {
        require(numElements>1500);
        numElements = 0;
    }

    // Gas DOS clear
    function clearDOS() public {

        // number depends on actual gas limit
        require(numElements>1500);
        array = new uint[](0);
        numElements = 0;
    }

    function getLengthArray() public view returns(uint) {
        return numElements;
    }

    function getRealLengthArray() public view returns(uint) {
        return array.length;
    }
}
