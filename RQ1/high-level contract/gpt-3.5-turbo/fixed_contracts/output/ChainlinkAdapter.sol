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
        int256 rawPrice = feeder.latestAnswer();
        require(rawPrice >= 0, 'Chainlink price cannot be negative');
        newPrice = uint256(rawPrice).mul(chainlinkDecimalsAdapter);
        timestamp = feeder.latestTimestamp();
    }
}
