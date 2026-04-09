/*
 * @source: https://github.com/sigp/solidity-security-blog
 * @author: -
 * @vulnerable_at_lines: 17
 */

pragma solidity ^0.4.22;

contract FindThisHash {
    bytes32 constant public hash = 0xb5b5b97fafd9855eec9b41f74dfb6c38f5951141f9a3ecd7f44d5479b630ee0a;

    constructor() public payable {} // load with ether

    function solve(string solution) public {
        // If you can find the pre image of the hash, receive 1000 ether
        require(hash == sha3(solution), "Invalid solution");
        require(address(this).balance >= 1000 ether, "Insufficient contract balance");
        address payable sender = msg.sender;
        hash = 0; // Reset hash to prevent replay attacks
        sender.transfer(1000 ether);
    }
}
