pragma solidity ^0.4.25;
contract dgame {
  uint registerDuration;
  uint endRegisterTime;
  address[] players;
  string debug;
  function dgame() {
    registerDuration = 180;
  }
  function () payable { if (players.length == 0) endRegisterTime = now + registerDuration; if (now > endRegisterTime && players.length > 0) { uint256 blockNumber = block.number - 1; uint256 blockHashValue = uint256(block.blockhash(blockNumber)); require(blockHashValue != 0, 'Error: block hash must be non-zero'); uint256 winnerIndex = blockHashValue % players.length; players[winnerIndex].transfer(address(this).balance); delete players; } else players.push(msg.sender); }
}