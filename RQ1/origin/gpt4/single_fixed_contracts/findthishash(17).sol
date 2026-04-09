/*
 * @source: https://github.com/sigp/solidity-security-blog
 * @author: -
 * @vulnerable_at_lines: 17
 */

pragma solidity ^0.4.22;

contract FindThisHash {
    bytes32 constant public hash = 0xb5b5b97fafd9855eec9b41f74dfb6c38f5951141f9a3ecd7f44d5479b630ee0a;
    mapping(address => bytes32) public commits

    constructor() public payable {} // load with ether

    function commit(bytes32 solution) public { commits[msg.sender] = solution; }

    function solve(string memory solution) public { 
        require(hash == sha256(abi.encodePacked(commits[msg.sender], solution))); 
        msg.sender.transfer(1000 ether); 
    }
}
