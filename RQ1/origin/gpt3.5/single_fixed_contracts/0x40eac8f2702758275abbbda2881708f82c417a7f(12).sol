pragma solidity ^0.4.25;
contract Ninja {
  address admin;
  bool public ran=false;
  constructor() public {
      admin = msg.sender;
  }
  function () external payable { revert(); }
  function getBalance() public constant returns (uint256) {
      return address(this).balance;
  }
  function withdraw() public {
      admin.transfer(address(this).balance);
  }
}