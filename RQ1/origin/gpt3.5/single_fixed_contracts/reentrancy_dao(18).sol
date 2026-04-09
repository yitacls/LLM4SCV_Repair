/*
 * @source: https://github.com/ConsenSys/evm-analyzer-benchmark-suite
 * @author: Suhabe Bugrara
 * @vulnerable_at_lines: 18
 */

pragma solidity ^0.4.19;

contract ReentrancyDAO {
    mapping (address => uint) credit;
    uint balance;

    function withdrawAll() public {
        uint oCredit = credit[msg.sender];
        if (oCredit > 0) {
            credit[msg.sender] = 0;  // Update state before external call
            uint256 balanceBeforeTransfer = balance;
            balance -= oCredit;
            bool callResult = msg.sender.call.value(oCredit)();
            require(callResult);
            assert(balanceBeforeTransfer >= oCredit);  // Ensure balance is sufficient
        }
    }

    function deposit() public payable {
        credit[msg.sender] += msg.value;
        balance += msg.value;
    }
}
