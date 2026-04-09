pragma solidity ^0.4.24;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                function add_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
                                uint256 c = a + b;
                                assert(c >= a);
                                return c;
                        }
                                
                                
                                
                        }
                contract Map is sGuardPlus {
address  public   owner;
uint256 []    map;
function set (uint256    key,uint256    value) public  {
if (map.length<=key)
{
map.length=add_uint256(key, 1);
}

map[key]=value;
}

function get (uint256    key) public view returns (uint256    ){
return map[key];
}

function withdraw () public  {
require(msg.sender==owner);
msg.sender.transfer(address(this).balance);
}

}
