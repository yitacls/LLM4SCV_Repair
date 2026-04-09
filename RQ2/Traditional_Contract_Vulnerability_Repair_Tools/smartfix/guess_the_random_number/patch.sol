contract SmartFix {
  address public smartfix_owner = msg.sender;
}

/*
 * @source: https://capturetheether.com/challenges/lotteries/guess-the-random-number/
 * @author: Steve Marx
 * @vulnerable_at_lines: 15
 */

pragma solidity ^0.4.21;

contract GuessTheRandomNumberChallenge is SmartFix {
    uint8 answer;

    function GuessTheRandomNumberChallenge() public payable {
        require(msg.value == 1 ether);
        // <yes> <report> BAD_RANDOMNESS
        require((block.number >= 1)); /* <FIX> Insert:BC */
        answer = uint8(keccak256(block.blockhash(block.number - 1), now));
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function guess(uint8 n) public payable {
        require((smartfix_owner == msg.sender)); /* <FIX> Insert */
        require(msg.value == 1 ether);

        if (n == answer) {
            msg.sender.transfer(2 ether);
        }
    }
}
