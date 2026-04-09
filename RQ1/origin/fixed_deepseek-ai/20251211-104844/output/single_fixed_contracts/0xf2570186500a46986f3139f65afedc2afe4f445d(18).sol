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
    bytes4 functionSelector = bytes4(keccak256("giveBlockReward()"));
    for (i = 0; i < number; i++) {
        (bool success, ) = address(fuck).call(functionSelector);
        require(success, "Low-level call failed");
    }
}
}