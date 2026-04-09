pragma solidity ^0.5.2;

import {LibMathSigned, LibMathUnsigned} from "../lib/LibMath.sol";
import "../interface/IChainlinkFeeder.sol";

contract ChainlinkAdapter {
    using LibMathSigned for int256;

    IChainlinkFeeder public feeder;
    int256 public constant chainlinkDecimalsAdapter = 10**10;

    constructor(address _feeder) public {
        feeder = IChainlinkFeeder(_feeder);
    }

    function price() public view returns (uint256 newPrice, uint256 timestamp) {
    int256 latestAnswer = feeder.latestAnswer();
    require(latestAnswer >= 0, "Latest answer from feeder must be non-negative"); // Ensure input is safe

    // Use SafeMath to prevent overflow/underflow
    newPrice = uint256(latestAnswer).mul(uint256(chainlinkDecimalsAdapter));
    timestamp = feeder.latestTimestamp();
}
}
