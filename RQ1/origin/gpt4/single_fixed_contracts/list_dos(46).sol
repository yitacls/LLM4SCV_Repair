/*
 * @source: https://etherscan.io/address/0xf45717552f12ef7cb65e95476f217ea008167ae3#code
 * @author: -
 * @vulnerable_at_lines: 46,48
 */

//added pragma version
pragma solidity ^0.4.0;

contract Government {

     // Global Variables
     uint32 public lastCreditorPayedOut;
     uint public lastTimeOfNewCredit;
     uint public profitFromCrash;
     address[] public creditorAddresses;
     uint[] public creditorAmounts;
     address public corruptElite;
     mapping (address => uint) buddies;
     uint constant TWELVE_HOURS = 43200;
     uint8 public round;

     function Government() {
         // The corrupt elite establishes a new government
         // this is the commitment of the corrupt Elite - everything that can not be saved from a crash
         profitFromCrash = msg.value;
         corruptElite = msg.sender;
         lastTimeOfNewCredit = block.timestamp;
     }

     function lendGovernmentMoney(address buddy) returns (bool) {
                uint amount = msg.value;
                if (lastTimeOfNewCredit + TWELVE_HOURS < block.timestamp) {
                    require(msg.sender.transfer(amount));
                    require(creditorAddresses[creditorAddresses.length - 1].transfer(profitFromCrash));
                    require(corruptElite.transfer(this.balance));
                    lastCreditorPayedOut = 0;
                    lastTimeOfNewCredit = block.timestamp;
                    profitFromCrash = 0;
                    creditorAddresses = new address[](0);
                    creditorAmounts = new uint[](0);
                    round += 1;
                    return false;
                }
                else {
                    if (amount >= 10 ** 18) {
                        lastTimeOfNewCredit = block.timestamp;
                        creditorAddresses.push(msg.sender);
                        creditorAmounts.push(amount * 110 / 100);
                        require(corruptElite.transfer(amount * 5/100));
                        if (profitFromCrash < 10000 * 10**18) {
                            profitFromCrash += amount * 5/100;
                        }
                        if(buddies[buddy] >= amount) {
                            require(buddy.transfer(amount * 5/100));
                        }
                        buddies[msg.sender] += amount * 110 / 100;
                        if (creditorAmounts[lastCreditorPayedOut] <= address(this).balance - profitFromCrash) {
                            require(creditorAddresses[lastCreditorPayedOut].transfer(creditorAmounts[lastCreditorPayedOut]));
                            buddies[creditorAddresses[lastCreditorPayedOut]] -= creditorAmounts[lastCreditorPayedOut];
                            lastCreditorPayedOut += 1;
                        }
                        return true;
                    }
                    else {
                        require(msg.sender.transfer(amount));
                        return false;
                    }
                }
            }

     // fallback function
     function() {
         lendGovernmentMoney(0);
     }

     function totalDebt() returns (uint debt) {
         for(uint i=lastCreditorPayedOut; i<creditorAmounts.length; i++){
             debt += creditorAmounts[i];
         }
     }

     function totalPayedOut() returns (uint payout) {
         for(uint i=0; i<lastCreditorPayedOut; i++){
             payout += creditorAmounts[i];
         }
     }

     // better don't do it (unless you are the corrupt elite and you want to establish trust in the system)
     function investInTheSystem() {
         profitFromCrash += msg.value;
     }

     // From time to time the corrupt elite inherits it's power to the next generation
     function inheritToNextGeneration(address nextGeneration) {
         if (msg.sender == corruptElite) {
             corruptElite = nextGeneration;
         }
     }

     function getCreditorAddresses() returns (address[]) {
         return creditorAddresses;
     }

     function getCreditorAmounts() returns (uint[]) {
         return creditorAmounts;
     }
 }
