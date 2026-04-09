pragma solidity ^0.4.18;
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
    uint256 c = a / b;
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
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;
  mapping(address => uint256) balances;
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }
}
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract StandardToken is ERC20, BasicToken {
  mapping (address => mapping (address => uint256)) internal allowed;
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
}
contract NomToken is StandardToken {
  event Mint(address indexed to, uint256 amount);
  address public owner;
  string public constant name = "Finom NOM Token"; 
  string public constant symbol = "NOM";
  uint32 public constant decimals = 18;
  uint256 public constant totalTokens = 113300000 * 1 ether;
  uint256 public initialIssueMinting = totalTokens.mul(45).div(100);  
  uint public constant initialIssueMintingDate = 1514764800;          
  bool public initialIssueMinted = false;
  uint256 public firstStageMinting = totalTokens.mul(15).div(100);    
  uint public constant firstStageMintingDate = 1579046400;            
  bool public firstStageMinted = false;
  uint256 public secondStageMinting = totalTokens.mul(20).div(100);   
  uint public constant secondStageMintingDate = 1594771200;           
  bool public secondStageMinted = false;
  uint256 public thirdStageMinting = totalTokens.mul(20).div(100);    
  uint public constant thirdStageMintingDate = 1610668800;            
  bool public thirdStageMinted = false;
  function NomToken() public {
    owner = msg.sender;
  }
  function mint() public returns (bool) {
    require(tx.origin == owner);  // fault line
    uint256 tokensToMint = 0;
    if (now > initialIssueMintingDate && !initialIssueMinted) {
        tokensToMint = tokensToMint.add(initialIssueMinting);
        initialIssueMinted = true;
    }
	if (now > firstStageMintingDate && !firstStageMinted) {
        tokensToMint = tokensToMint.add(firstStageMinting);
        firstStageMinted = true;
    }
    if (now > secondStageMintingDate && !secondStageMinted) {
        tokensToMint = tokensToMint.add(secondStageMinting);
        secondStageMinted = true;
    }
    if (now > thirdStageMintingDate && !thirdStageMinted) {
        tokensToMint = tokensToMint.add(thirdStageMinting);
        thirdStageMinted = true;
    }
    require(tokensToMint > 0);
    uint256 newTotalSupply = totalSupply.add(tokensToMint);
    require(newTotalSupply <= totalTokens);
    totalSupply = totalSupply.add(tokensToMint);
    balances[owner] = balances[owner].add(tokensToMint);
    Mint(owner, tokensToMint);
    Transfer(address(0), owner, tokensToMint);
    return true;
  }
}