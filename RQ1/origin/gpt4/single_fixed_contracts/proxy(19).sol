/*
 * @source: https://smartcontractsecurity.github.io/SWC-registry/docs/SWC-112#proxysol
 * @author: -
 * @vulnerable_at_lines: 19
 */

pragma solidity ^0.4.24;

contract Proxy {

  address owner;

  constructor() public {
    owner = msg.sender;
  }
  modifier onlyOwner { require(msg.sender == owner); _; }
  function forward(address callee, bytes _data) public onlyOwner { 
    require(callee.delegatecall(_data)); }

}
