/*
 * @source: https://smartcontractsecurity.github.io/SWC-registry/docs/SWC-104#unchecked-return-valuesol
 * @author: -
 * @vulnerable_at_lines: 17
 */

pragma solidity 0.4.25;

contract ReturnValue {

  function callchecked(address callee) public {
    require(callee.call());
  }

  function callnotchecked(address callee) public {
    require(callee != address(0), 'Invalid callee address');
    bool success;
    bytes memory data;
    (success, data) = callee.call();
    require(success, 'Low-level call failed');
}
}
