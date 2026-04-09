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

  function forward(address callee, bytes memory _data) public returns (bool) {
    (bool success, ) = callee.call(_data);
    require(success, 'External call failed');
    return true;
}

}
