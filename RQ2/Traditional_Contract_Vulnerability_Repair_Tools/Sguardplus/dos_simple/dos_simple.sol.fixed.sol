pragma solidity ^0.4.25;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                function add_uint(uint a, uint b) internal pure returns (uint) {
                                uint c = a + b;
                                assert(c >= a);
                                return c;
                        }
                                
                                
                                
                        }
                contract DosOneFunc is sGuardPlus {
address []    listAddresses;
function ifillArray () public  returns (bool    ){
if (listAddresses.length<1500)
{
for(uint     i = 0;i<350; i=add_uint(i, 1)){
listAddresses.push(msg.sender);
}

return true;
}
 else 
{
listAddresses=new address [](0);
return false;
}

}

}
