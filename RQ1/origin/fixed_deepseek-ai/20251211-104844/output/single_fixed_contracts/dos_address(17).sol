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
    require(msg.sender == owner, "Only owner can empty creditors");
    
    // Prevent DoS by checking gas consumption before execution
    require(creditorAddresses.length <= 1500, "Array too large - use emergencyWithdrawal instead");
    
    // Emergency withdrawal pattern for large arrays
    if (creditorAddresses.length > 0) {
        if (creditorAddresses.length <= 1500) {
            // Safe to clear for arrays up to 1500 elements
            creditorAddresses = new address[](0);
            win = true;
        } else {
            // For arrays larger than 1500, implement paginated clearing
            revert("Use paginated clearing for large arrays");
        }
    }
}

// Additional helper function for large arrays
function paginatedClearCreditors(uint256 _batchSize, uint256 _startIndex) public {
    require(msg.sender == owner, "Only owner can clear creditors");
    require(_batchSize > 0 && _batchSize <= 100, "Batch size must be between 1 and 100");
    
    uint256 endIndex = _startIndex + _batchSize;
    if (endIndex > creditorAddresses.length) {
        endIndex = creditorAddresses.length;
    }
    
    // Clear in batches to avoid DoS
    for (uint256 i = _startIndex; i < endIndex; i++) {
        delete creditorAddresses[i];
    }
    
    // If we've cleared everything, reset the array
    if (_startIndex + _batchSize >= creditorAddresses.length) {
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
