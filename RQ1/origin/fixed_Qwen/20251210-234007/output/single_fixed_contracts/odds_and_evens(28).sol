/*
 * @source: http://blockchain.unica.it/projects/ethereum-survey/attacks.html#oddsandevens
 * @author: -
 * @vulnerable_at_lines: 25,28
 */

pragma solidity ^0.4.2;

contract OddsAndEvens{

  struct Player {
    address addr;
    uint number;
  }

  Player[2] public players;         //public only for debug purpose

  uint8 tot;
  address owner;

  function OddsAndEvens() {
    owner = msg.sender;
  }
// <yes> <report> FRONT_RUNNING
  function commit(bytes32 hash) payable {
    if (msg.value != 1 ether) throw;
    commits[msg.sender] = hash;
}

function reveal(uint number, uint nonce) {
    if (commits[msg.sender] == 0) throw;
    bytes32 hash = sha3(number, nonce);
    if (commits[msg.sender] != hash) throw;
    players[tot] = Player(msg.sender, number);
    tot++;
    if (tot == 2) andTheWinnerIs();
}

  function andTheWinnerIs() private {
    bool res ;
    uint n = players[0].number+players[1].number;
    if (n%2==0) {
      res = players[0].addr.send(1800 finney);
    }
    else {
      res = players[1].addr.send(1800 finney);
    }

    delete players;
    tot=0;
  }

  function getProfit() {
    if(msg.sender!=owner) throw;
    bool res = msg.sender.send(this.balance);
  }

}
