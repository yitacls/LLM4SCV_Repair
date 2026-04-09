/* ORIGINAL: pragma solidity ^0.4.25; */


interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


contract Disperse {
    function disperseEther(address[] calldata recipients, uint256[] calldata values) external payable onlyOwner {
        require(recipients.length == values.length, 'Length mismatch between recipients and values');

        for (uint256 i = 0; i < recipients.length; i++) {
            recipients[i].transfer(values[i]);
        }

        uint256 contractBalance = address(this).balance;
        if (contractBalance > 0) {
            msg.sender.transfer(contractBalance);
        }
    }

    function disperseToken(IERC20 token, address[] recipients, uint256[] values) external {
        uint256 total = 0;
        for (uint256 i = 0; i < recipients.length; i++)
            total += values[i];
        require(token.transferFrom(msg.sender, address(this), total));
        for (i = 0; i < recipients.length; i++)
            require(token.transfer(recipients[i], values[i]));
    }

    function disperseTokenSimple(IERC20 token, address[] recipients, uint256[] values) external {
        for (uint256 i = 0; i < recipients.length; i++)
            require(token.transferFrom(msg.sender, recipients[i], values[i]));
    }
}
