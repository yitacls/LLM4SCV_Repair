/*
 * @source: etherscan.io 
 * @author: -
 * @vulnerable_at_lines: 12
 */

pragma solidity ^0.4.10;

contract Caller {
    function callAddress(address a) {
    require(a.call(), "Low-level call failed");
}

}