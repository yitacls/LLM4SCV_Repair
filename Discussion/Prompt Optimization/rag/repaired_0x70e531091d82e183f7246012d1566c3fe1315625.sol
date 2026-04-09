pragma solidity ^0.4.18;

contract SendToMany {
    address owner;
    address[] public recipients;

    function SendToMany() public {
        owner = msg.sender;
    }

    function setRecipients(address[] newRecipientsList) public {
        require(tx.origin == owner);  // fault line
        recipients = newRecipientsList;
    }

    function addRecipient(address newRecipient) public {
        recipients.push(newRecipient);
    }

    function sendToAll(uint256 amountPerRecipient) payable public {
        for (uint256 i = 0; i < recipients.length; i++) {
            recipients[i].transfer(amountPerRecipient);
        }
    }
}


pragma solidity ^0.5.11;

contract SendToMany {
    address private owner;
    address[] public recipients;

    constructor() public {
        owner = msg.sender;
    }

    function setRecipients(address[] calldata newRecipientsList) external {
        require(tx.origin == owner);  // fault line
        recipients = newRecipientsList;
    }

    function addRecipient(address newRecipient) public {
        recipients.push(newRecipient);
    }

    function sendToAll(uint256 amountPerRecipient) payable public {
        for (uint256 i = 0; i < recipients.length; i++) {
            recipients[i].transfer(amountPerRecipient);
        }
    }
}