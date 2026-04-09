/*
 * @source: etherscan.io 
 * @author: -
 * @vulnerable_at_lines: 44,97
 */

pragma solidity ^0.4.18;

contract Ownable
{
    address newOwner;
    address owner = msg.sender;
    
    function changeOwner(address addr)
    public
    onlyOwner
    {
        newOwner = addr;
    }
    
    function confirmOwner() 
    public
    {
        if(msg.sender==newOwner)
        {
            owner=newOwner;
        }
    }
    
    modifier onlyOwner
    {
        if(owner == msg.sender)_;
    }
}

contract Token is Ownable
{
    address owner = msg.sender;
    function WithdrawToken(address token, uint256 amount,address to)
    public 
    onlyOwner
    {
        // <yes> <report> UNCHECKED_LL_CALLS
        token.call(bytes4(sha3("transfer(address,uint256)")),to,amount); 
    }
}

contract TokenBank is Token
{
    uint public MinDeposit;
    mapping (address => uint) public Holders;
    
     ///Constructor
    function initTokenBank()
    public
    {
        owner = msg.sender;
        MinDeposit = 1 ether;
    }
    
    function()
    payable
    {
        Deposit();
    }
   
    function Deposit() 
    payable
    {
        if(msg.value>MinDeposit)
        {
            Holders[msg.sender]+=msg.value;
        }
    }
    
    function WitdrawTokenToHolder(address _to,address _token,uint _amount)
    public
    onlyOwner
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            WithdrawToken(_token,_amount,_to);     
        }
    }
   
        function WithdrawToHolder(address _addr, uint _wei) 
        public
        onlyOwner
    {
        // Validate inputs and state
        require(_addr != address(0), "Invalid address");
        require(_wei > 0, "Amount must be greater than 0");
        require(Holders[msg.sender] >= _wei, "Insufficient balance");
        require(Holders[_addr] >= _wei, "Recipient insufficient balance");
        
        // Update state before external call (checks-effects-interactions)
        Holders[msg.sender] -= _wei;
        Holders[_addr] -= _wei;
        
        // Use transfer instead of low-level call for security
        _addr.transfer(_wei);
        
        // Optional: Emit an event for transparency
        // Withdrawn(_addr, _wei);
    }
    
 
}