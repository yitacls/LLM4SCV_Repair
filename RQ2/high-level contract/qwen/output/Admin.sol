//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;

contract Admin {

    // Listing all admins
    address [] public admins;

    // Modifier for easier checking if user is admin
    mapping(address => bool) public isAdmin;

    // Modifier restricting access to only admin
    modifier onlyAdmin {
        require(isAdmin[msg.sender] == true, "not admin");
        _;
    }

    // Constructor to set initial admins during deployment
    constructor (address [] memory _admins) public {
        for(uint i = 0; i < _admins.length; i++) {
            admins.push(_admins[i]);
            isAdmin[_admins[i]] = true;
        }
    }

    function addAdmin(
        address _adminAddress
    )
    external
    onlyAdmin
    {
        // Can't add 0x address as an admin
        require(_adminAddress != address(0x0), "[RBAC] : Admin must be != than 0x0 address");
        // Can't add existing admin
        require(isAdmin[_adminAddress] == false, "[RBAC] : Admin already exists.");
        // Add admin to array of admins
        admins.push(_adminAddress);
        // Set mapping
        isAdmin[_adminAddress] = true;
    }

    // SWC-113-DoS with Failed Call: L43-68
            function removeAdmin(
        address _adminAddress
    )
    external
    onlyAdmin
    {
        // Admin has to exist
        require(isAdmin[_adminAddress] == true, "Admin does not exist");

        // Find the admin to remove
        uint index = admins.length;
        for (uint i = 0; i < admins.length; i++) {
            if (admins[i] == _adminAddress) {
                index = i;
                break;
            }
        }
        
        // Revert if admin was not found (should not happen due to require check)
        require(index < admins.length, "Admin not found in array");

        // Move the last element to the position of the element to delete
        admins[index] = admins[admins.length - 1];
        
        // Remove the last element
        admins.pop();

        // Update mapping
        isAdmin[_adminAddress] = false;
    }

    // Fetch all admins
    function getAllAdmins()
    external
    view
    returns (address [] memory)
    {
        return admins;
    }

}
