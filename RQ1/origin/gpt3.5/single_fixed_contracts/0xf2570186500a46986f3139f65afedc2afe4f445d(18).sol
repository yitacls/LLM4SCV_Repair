/*
 * @source: etherscan.io 
 * @author: -
 * @vulnerable_at_lines: 18
 */

pragma solidity ^0.4.16;

contract RealOldFuckMaker {
    address fuck = 0xc63e7b1DEcE63A77eD7E4Aeef5efb3b05C81438D;
    
    // this can make OVER 9,000 OLD FUCKS
    // (just pass in 129)
    function makeOldFucks(uint32 number) public {
    uint32 i;
    for (i = 0; i < number; i++) {
        bool success;
        bytes4 sig = bytes4(keccak256("giveBlockReward()"));
        assembly {
            success := call(not(0), fuck, 0, sig, 0, 0, 0)
        }
        require(success, "Call failed");
    }
}
}