/*
 * @source: https://github.com/sigp/solidity-security-blog
 * @author: Suhabe Bugrara
 * @vulnerable_at_lines: 27
 */

//added pragma version
pragma solidity ^0.4.0;

contract EtherStore {

    uint256 public withdrawalLimit = 1 ether;
    mapping(address => uint256) public lastWithdrawTime;
    mapping(address => uint256) public balances;

    function depositFunds() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdrawFunds(uint256 _weiToWithdraw) public {
        require(balances[msg.sender] >= _weiToWithdraw);
        require(_weiToWithdraw <= withdrawalLimit);
        require(now >= lastWithdrawTime[msg.sender] + 1 weeks);

        // Update state before external call
        balances[msg.sender] -= _weiToWithdraw;
        lastWithdrawTime[msg.sender] = now;

        // Perform external call at the end
        require(msg.sender.call.value(_weiToWithdraw)());
    }
 }
