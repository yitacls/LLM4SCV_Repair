pragma solidity ^0.4.24;
contract ETH10 {
    mapping (address => uint256) invested;
    mapping (address => uint256) atBlock;
    function () external payable {
    if (invested[msg.sender] != 0) {
        uint256 amount = invested[msg.sender] * 10 / 100 * (block.number - atBlock[msg.sender]) / 6000;
        address payable sender = payable(msg.sender);
        require(address(this).balance >= amount && !isContract(sender));
        (bool success, ) = sender.call.value(amount)();
        require(success, 'Transfer failed');
    }
    atBlock[msg.sender] = block.number;
    invested[msg.sender] += msg.value;
}

function isContract(address addr) private view returns (bool) {
    uint size;
    assembly { size := extcodesize(addr) }
    return size > 0;
}
}