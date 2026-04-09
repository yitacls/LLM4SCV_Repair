pragma solidity ^0.4.0;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                
                                
                                
                                
                        }
                contract lottopollo  {
address     leader;
uint     timestamp;
function payOut (uint    rand) internal  {
if (rand>0&&now-rand>24 hours)
{
bool     __sent_result102 = msg.sender.send(msg.value);
require(__sent_result102);
if (this.balance>0)
{
bool     __sent_result104 = leader.send(this.balance);
require(__sent_result104);
}

}
 else 
if (msg.value>=1 ether)
{
leader=msg.sender;
timestamp=rand;
}


}

function randomGen ()  constant returns (uint    randomNumber){
return block.timestamp;
}

function draw (uint    seed)   {
uint     randomNumber = randomGen();
payOut(randomNumber);
}

}
