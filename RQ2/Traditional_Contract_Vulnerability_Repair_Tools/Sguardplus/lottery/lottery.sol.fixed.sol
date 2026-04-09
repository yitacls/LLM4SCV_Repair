pragma solidity ^0.4.0;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                function add_uint(uint a, uint b) internal pure returns (uint) {
                                uint c = a + b;
                                assert(c >= a);
                                return c;
                        }
                                
                                
                                
                        }
                contract Lottery is sGuardPlus {
event GetBet (uint    betAmount,uint    blockNumber,bool    won);
struct Bet {
uint     betAmount;
uint     blockNumber;
bool     won;
}
address  private   organizer;
Bet [] private   bets;
constructor ()   {
organizer=msg.sender;
}

function ()   {
throw;}

function makeBet ()   {
bool     won = (block.number%2)==0;
bets.push(Bet(msg.value, block.number, won));
if (won)
{
if ( ! msg.sender.send(msg.value))
{
throw;}

}

}

function getBets ()   {
if (msg.sender!=organizer)
{
throw;}

for(uint     i = 0;i<bets.length; i=add_uint(i, 1)){
GetBet(bets[i].betAmount, bets[i].blockNumber, bets[i].won);
}

}

function destroy ()   {
if (msg.sender!=organizer)
{
throw;}

suicide(organizer);
}

}
