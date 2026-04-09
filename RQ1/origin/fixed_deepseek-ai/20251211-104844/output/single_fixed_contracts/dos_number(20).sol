/*
 * @source: https://github.com/SmartContractSecurity/SWC-registry/blob/master/test_cases/dos_gas_limit/dos_number.sol
 * @author: -
 * @vulnerable_at_lines: 18,19,20,21,22
 */

pragma solidity ^0.4.25;

contract DosNumber {

    uint numElements = 0;
    uint[] array;

    function insertNnumbers(uint256 value, uint256 numbers) public {
    require(numbers > 0, "Numbers must be greater than 0");
    require(numbers <= 100, "Batch size too large (max: 100)");
    
    // Pre-allocate memory if needed
    uint256 newTotal = numElements + numbers;
    if (newTotal > array.length) {
        array.length = newTotal;
    }
    
    // Fill the array with values
    for (uint256 i = 0; i < numbers; i++) {
        array[numElements + i] = value;
    }
    
    // Update element count once
    numElements = newTotal;
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
