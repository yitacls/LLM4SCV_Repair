/*
 * @source: https://github.com/trailofbits/not-so-smart-contracts/blob/master/denial_of_service/auction.sol
 * @author: -
 * @vulnerable_at_lines: 23
 */

pragma solidity ^0.4.15;

//Auction susceptible to DoS attack
contract DosAuction {
  address currentFrontrunner;
  uint currentBid;

  //Takes in bid, refunding the frontrunner if they are outbid
  function bid() payable {
    require(msg.value > currentBid);

    if (currentFrontrunner != 0) {
        uint refundAmount = currentBid;
        currentFrontrunner.transfer(refundAmount);
    }

    currentFrontrunner = msg.sender;
    currentBid = msg.value;
}
}
