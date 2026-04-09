pragma solidity ^0.4.21;

contract Etherwow{
    function userRollDice(uint, address) payable {uint;address;}
}
contract FixBet31{
    bool private isLocked;
    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }
    address public owner;
    Etherwow public etherwow;
    bool public bet;
    function FixBet31(){
        owner = msg.sender;
    }
    function ownerSetEtherwowAddress(address newEtherwowAddress) public
        onlyOwner
    {
       etherwow = Etherwow(newEtherwowAddress);
    }
    function ownerSetMod(bool newMod) public
        onlyOwner
    {
        bet = newMod;
    }

    modifier noReentrancy { 
        require(!isLocked, 'No reentrancy'); 
        isLocked = true;
         _; isLocked = false;
     }

    function () payable noReentrancy {
        if (bet == true) {
            require(msg.value == 1000000000000000000);
            etherwow.userRollDice.value(msg.value)(31, msg.sender);
        } else {
            return;
        }
    }

}