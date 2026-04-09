pragma solidity ^0.4.0;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                function add_uint(uint a, uint b) internal pure returns (uint) {
                                uint c = a + b;
                                assert(c >= a);
                                return c;
                        }
function sub_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
                                assert(b <= a);
                                return a - b;
                        }
                                
                                
                                
                        }
                contract Governmental is sGuardPlus {
address  public   owner;
address  public   lastInvestor;
uint  public   jackpot = 1 ether;
uint  public   lastInvestmentTimestamp;
uint  public   ONE_MINUTE = 1 minutes;
constructor ()   {
owner=msg.sender;
if (msg.value<1 ether)
throw;
}

function invest ()   {
if (msg.value<jackpot/2)
throw;
lastInvestor=msg.sender;
jackpot+=msg.value/2;
lastInvestmentTimestamp=block.timestamp;
}

function resetInvestment ()   {
if (block.timestamp<add_uint(lastInvestmentTimestamp, ONE_MINUTE))
throw;
bool     __sent_result100 = lastInvestor.send(jackpot);
require(__sent_result100);
bool     __sent_result101 = owner.send(sub_uint256(this.balance, 1 ether));
require(__sent_result101);
lastInvestor=0;
jackpot=1 ether;
lastInvestmentTimestamp=0;
}

}
contract Attacker  {
function attack (address    target,uint    count)   {
if (0<=count&&count<1023)
{
this.attack.gas(msg.gas-2000)(target, count+1);
}
 else 
{
Governmental(target).resetInvestment();
}

}

}
