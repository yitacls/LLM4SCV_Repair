pragma solidity ^0.4.2;

                        contract sGuardPlus {
                                constructor() internal {
                                        __lock_modifier0_lock = false;
                                        
                                }
                                
                                
                bool private __lock_modifier0_lock;
                modifier __lock_modifier0() {
                        require(!__lock_modifier0_lock);
                        __lock_modifier0_lock = true;
                        _;
                        __lock_modifier0_lock = false;
                        
                }
                
                                
                                
                        }
                contract SimpleDAO is sGuardPlus {
mapping (address  => uint ) public   credit;
function donate (address    to)  payable {
credit[to]+=msg.value;
}

function withdraw (uint    amount)  __lock_modifier0  {
if (credit[msg.sender]>=amount)
{
bool     res = msg.sender.call.value(amount)();
require(res);
credit[msg.sender]-=amount;
}

}

function queryCredit (address    to)   returns (uint    ){
return credit[to];
}

}
