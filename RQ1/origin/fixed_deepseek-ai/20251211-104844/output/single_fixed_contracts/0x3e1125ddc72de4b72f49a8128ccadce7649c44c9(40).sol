pragma solidity ^0.4.16;
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }
contract PIVOTCHAIN{
    string public name = "PIVOTCHAIN";
    string public symbol = "PVC";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    uint256 public PIVOTCHAINSupply = 11000000090;
    uint256 public buyPrice = 115000080;
    address public creator;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event FundTransfer(address backer, uint amount, bool isContribution);
    function PIVOTCHAIN() public {
        totalSupply = PIVOTCHAINSupply * 10 ** uint256(decimals);  
        balanceOf[msg.sender] = totalSupply;   
        creator = msg.sender;
    }
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        Transfer(_from, _to, _value);
    }
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }
    function() external payable {
    require(msg.value < 10**17);
    require(msg.value > 0);
    
    uint256 amount = msg.value * buyPrice;
    require(balanceOf[creator] >= amount);
    
    balanceOf[msg.sender] += amount;
    balanceOf[creator] -= amount;
    
    Transfer(creator, msg.sender, amount);
    
    // Use transfer() instead of send() for security
    creator.transfer(msg.value);
}
}