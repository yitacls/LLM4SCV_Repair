pragma solidity ^0.4.20;
contract LocusOne {
    	address devAcct;
    	address potAcct;
    	uint fee;
    	uint pot;
    function() public payable {
    _split(msg.value); 
    }
    function _split(uint _stake) internal {
        if (msg.value < 0.05 ether || msg.value > 1000000 ether)
            revert();
        devAcct = 0x1daa0BFDEDfB133ec6aEd2F66D64cA88BeC3f0B4;
        potAcct = 0x708294833AEF21a305200b3463A832Ac97852f2e;        
        fee = div(_stake, 5);
        pot = sub(_stake, fee);
        devAcct.send(fee);  // fault line
        potAcct.transfer(pot);
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
 }