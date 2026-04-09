pragma solidity ^0.4.24;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                function add_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
                                uint256 c = a + b;
                                assert(c >= a);
                                return c;
                        }
function sub_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
                                assert(b <= a);
                                return a - b;
                        }
                                
                                
                                
                        }
                contract Wallet is sGuardPlus {
address     creator;
mapping (address  => uint256 )    balances;
constructor () public  {
creator=msg.sender;
}

function deposit () public payable {
assert(add_uint256(balances[msg.sender], msg.value)>balances[msg.sender]);
balances[msg.sender]=add_uint256(balances[msg.sender], msg.value);
}

function withdraw (uint256    amount) public  {
require(amount>=balances[msg.sender]);
msg.sender.transfer(amount);
balances[msg.sender]=sub_uint256(balances[msg.sender], amount);
}

function migrateTo (address    to) public  {
require(creator==msg.sender);
to.transfer(this.balance);
}

}
