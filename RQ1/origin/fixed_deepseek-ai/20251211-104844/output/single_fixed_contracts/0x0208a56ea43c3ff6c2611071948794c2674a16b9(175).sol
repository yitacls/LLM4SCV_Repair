/**
*Submitted for verification at Etherscan.io on 2019-12-11
* http://blockchainbits.in/
*/

// ORIGINAL: pragma solidity 0.4.18;


/**
* @title SafeMath
* @dev Math operations with safety checks that throw on error
*/
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

  contract ERC20 {
  function totalSupply()public view returns (uint total_Supply);
  function balanceOf(address _owner)public view returns (uint256 balance);
  function allowance(address _owner, address _spender)public view returns (uint remaining);
  function transferFrom(address _from, address _to, uint _amount)public returns (bool ok);
  function approve(address _spender, uint _amount)public returns (bool ok);
  function transfer(address _to, uint _amount)public returns (bool ok);
  event Transfer(address indexed _from, address indexed _to, uint _amount);
  event Approval(address indexed _owner, address indexed _spender, uint _amount);
}

contract ERBIUMCOIN is ERC20
{
    using SafeMath for uint256;
    string public constant symbol = "ERB";
    string public constant name = "ErbiumCoin";
    uint8 public constant decimals = 10;
    // 10 million total supply // muliplies dues to decimal precision
    uint256 public _totalSupply = 10000000 * 10 **10;     // 10 million supply           
    // Balances for each account
    mapping(address => uint256) balances;   
    // Owner of this contract
    address public owner;
    
    mapping (address => mapping (address => uint)) allowed;
    
    uint256 public supply_increased;
    
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    event LOG(string e,uint256 value);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }
