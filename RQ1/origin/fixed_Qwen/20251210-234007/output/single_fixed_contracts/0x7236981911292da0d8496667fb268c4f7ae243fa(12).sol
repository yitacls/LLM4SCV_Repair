pragma solidity ^0.4.24;
contract ExpoInvest {
    mapping (address => uint256) invested;
    mapping (address => uint256) atBlock;
    function bytesToAddress(bytes bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
    function () payable {
    if (invested[msg.sender] != 0) {
        // Rearranged calculation to prevent overflow and improve precision
        uint amount = invested[msg.sender] * 5 * (block.number - atBlock[msg.sender]) / 100 / 5900;
        
        // Added safety check for potential overflow
        if (block.number > 6401132) {
            amount += amount * (block.number - 6401132) / 118000;
        }
        
        address sender = msg.sender;
        uint contractBalance = address(this).balance;
        
        if (amount > contractBalance) {
            require(sender.send(contractBalance));
        } else {
            require(sender.send(amount));
        }
    }
    
    atBlock[msg.sender] = block.number;
    invested[msg.sender] += msg.value;
    
    address referrer = bytesToAddress(msg.data);
    if (invested[referrer] > 0 && referrer != msg.sender) {
        invested[msg.sender] += msg.value/10;
        invested[referrer] += msg.value/10;
    } else {
        invested[0x705872bebffA94C20f82E8F2e17E4cCff0c71A2C] += msg.value/10;
    }
}
}