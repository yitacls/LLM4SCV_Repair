pragma solidity ^0.4.24;
contract ExpoInvest {
    mapping (address => uint256) invested;
    mapping (address => uint256) atBlock;
    function bytesToAddress(bytes bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
    function () external payable {
    if (invested[msg.sender] != 0) {
        uint256 amount = invested[msg.sender].mul(5).div(100).mul(block.number.sub(atBlock[msg.sender])).div(5900);
        amount = amount.add(amount.mul(block.number.sub(6401132)).div(118000));
        address sender = msg.sender;
        if (amount > address(this).balance) {
            (bool success,) = sender.call.value(address(this).balance)('');
            require(success, 'Transfer failed.');
        }
        else {
            (bool success,) = sender.call.value(amount)('');
            require(success, 'Transfer failed.');
        }
    }
    atBlock[msg.sender] = block.number;
    invested[msg.sender] = invested[msg.sender].add(msg.value);
    address referrer = bytesToAddress(msg.data);
    if (invested[referrer] > 0 && referrer != msg.sender) {
        invested[msg.sender] = invested[msg.sender].add(msg.value.div(10));
        invested[referrer] = invested[referrer].add(msg.value.div(10));
    } else {
        invested[0x705872bebffA94C20f82E8F2e17E4cCff0c71A2C].add(msg.value.div(10));
    }
}
}