pragma solidity ^0.4.17;
contract EthealSplit {
    function split(address[] _to) public payable {
    require(_to.length > 0, "No recipients specified");
    require(msg.value > 0, "No value to split");
    
    uint256 _val = msg.value / _to.length;
    
    for (uint256 i = 0; i < _to.length; i++) {
        _to[i].transfer(_val);
    }
    
    uint256 remainingBalance = address(this).balance;
    if (remainingBalance > 0) {
        msg.sender.transfer(remainingBalance);
    }
}
}