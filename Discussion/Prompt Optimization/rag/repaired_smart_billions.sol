pragma solidity ^0.4.13;

library SafeMath {
  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }
  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20Basic {
  uint public totalSupply;
  address public owner; //owner
  address public animator; //animator
  function balanceOf(address who) constant returns (uint);
  function transfer(address to, uint value);
  event Transfer(address indexed from, address indexed to, uint value);
  function commitDividend(address who) internal; // pays remaining dividend
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint);
  function transferFrom(address from, address to, uint value);
  function approve(address spender, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint;
  mapping(address => uint) balances;

  modifier onlyPayloadSize(uint size) {
     assert(msg.data.length >= size + 4);
     _;
  }
  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) {
    commitDividend(msg.sender);
    balances[msg.sender] = balances[msg.sender].sub(_value);
    if(_to == address(this)) {
        commitDividend(owner);
        balances[owner] = balances[owner].add(_value);
        Transfer(msg.sender, owner, _value);
    }
    else {
        commitDividend(_to);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
    }
  }
  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }
}

contract StandardToken is BasicToken, ERC20 {
  mapping (address => mapping (address => uint)) allowed;

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) {
    var _allowance = allowed[_from][msg.sender];
    commitDividend(_from);
    commitDividend(_to);
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
  }
  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on beahlf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint _value) {
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    assert(!((_value != 0) && (allowed[msg.sender][_spender] != 0)));
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
  }
  /**
   * @dev Function to check the amount of tokens than an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint specifing the amount of tokens still avaible for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }
}

contract SmartBillions is StandardToken {

    // metadata
    string public constant name = "SmartBillions Token";
    string public constant symbol = "PLAY";
    uint public constant decimals = 0;

    // contract state
    struct Wallet {
        uint balance; // current balance of user
        uint lastDividendPeriod; // last processed dividend period of user's tokens
        uint nextWithdrawBlock; // next withdrawal possible after this block number
    }
    mapping (address => Wallet) wallets;
    struct Bet {
        uint value; // bet size
        uint betHash; // selected numbers
        uint blockNum; // blocknumber when lottery runs
    }
    mapping (address => Bet) bets;

    uint public walletBalance = 0; // sum of funds in wallets

    // investment parameters
    uint public investStart = 1; // investment start block, 0: closed, 1: preparation
    uint public investBalance = 0; // funding from investors
    uint public investBalanceMax = 200000 ether; // maximum funding
    uint public dividendPeriod = 1;
    uint[] public dividends; // dividens collected per period, growing array

    // betting parameters
    uint public maxWin = 0; // maximum prize won
    uint public hashFirst = 0; // start time of building hashes database
    uint public hashLast = 0; // last saved block of hashes
    uint public hashNext = 0; // next available bet block.number
    uint public hashBetSum = 0; // used bet volume of next block
    uint public hashBetMax = 5 ether; // maximum bet size per block
    uint[] public hashes; // space for storing lottery results

    // constants
    uint public hashesSize = 16384; // 30 days of blocks
    uint public coldStoreLast = 0; // block of last cold store transfer

    // events
    event LogBet(address indexed player, uint bethash, uint blocknumber, uint betsize);
    event LogLoss(address indexed player, uint bethash, uint hash);
    event LogWin(address indexed player, uint bethash, uint hash, uint prize);
    event LogInvestment(address indexed investor, address indexed partner, uint amount);
    event LogRecordWin(address indexed player, uint amount);
    event LogLate(address indexed player, uint playerBlockNumber, uint currentBlockNumber);
    event LogDividend(address indexed investor, uint amount, uint period);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyAnimator() {
        require(msg.sender == animator);
        _;
    }

    // constructor
    function SmartBillions() {
        owner = msg.sender;
        animator = msg.sender;
        wallets[owner].lastDividendPeriod = dividendPeriod;
        dividends.push(0); // not used
        dividends.push(0); // current dividend
    }

    // Add your functions here

}