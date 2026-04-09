/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;
pragma experimental ABIEncoderV2;

import "@0x/contracts-erc20/contracts/src/v06/IERC20TokenV06.sol";
import "@0x/contracts-erc20/contracts/src/v06/IEtherTokenV06.sol";
import "../migrations/LibMigrate.sol";
import "../external/IAllowanceTarget.sol";
import "../fixins/FixinCommon.sol";
import "./IFeature.sol";
import "./IUniswapFeature.sol";


/// @dev VIP uniswap fill functions.
contract UniswapFeature is
    IFeature,
    IUniswapFeature,
    FixinCommon
{
    /// @dev Name of this feature.
    string public constant override FEATURE_NAME = "UniswapFeature";
    /// @dev Version of this feature.
    uint256 public immutable override FEATURE_VERSION = _encodeVersion(1, 1, 0);
    /// @dev A bloom filter for tokens that consume all gas when `transferFrom()` fails.
    bytes32 public immutable GREEDY_TOKENS_BLOOM_FILTER;
    /// @dev WETH contract.
    IEtherTokenV06 private immutable WETH;
    /// @dev AllowanceTarget instance.
    IAllowanceTarget private immutable ALLOWANCE_TARGET;

    // 0xFF + address of the UniswapV2Factory contract.
    uint256 constant private FF_UNISWAP_FACTORY = 0xFF5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f0000000000000000000000;
    // 0xFF + address of the (Sushiswap) UniswapV2Factory contract.
    uint256 constant private FF_SUSHISWAP_FACTORY = 0xFFC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac0000000000000000000000;
    // Init code hash of the UniswapV2Pair contract.
    uint256 constant private UNISWAP_PAIR_INIT_CODE_HASH = 0x96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f;
    // Init code hash of the (Sushiswap) UniswapV2Pair contract.
    uint256 constant private SUSHISWAP_PAIR_INIT_CODE_HASH = 0xe18a34eb0e04b04f7a0ac29a6e80748dca96319b42c54d679cb821dca90c6303;
    // Mask of the lower 20 bytes of a bytes32.
    uint256 constant private ADDRESS_MASK = 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff;
    // ETH pseudo-token address.
    uint256 constant private ETH_TOKEN_ADDRESS_32 = 0x000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee;
    // Maximum token quantity that can be swapped against the UniswapV2Pair contract.
    uint256 constant private MAX_SWAP_AMOUNT = 2**112;

    // bytes4(keccak256("executeCall(address,bytes)"))
    uint256 constant private ALLOWANCE_TARGET_EXECUTE_CALL_SELECTOR_32 = 0xbca8c7b500000000000000000000000000000000000000000000000000000000;
    // bytes4(keccak256("getReserves()"))
    uint256 constant private UNISWAP_PAIR_RESERVES_CALL_SELECTOR_32 = 0x0902f1ac00000000000000000000000000000000000000000000000000000000;
    // bytes4(keccak256("swap(uint256,uint256,address,bytes)"))
    uint256 constant private UNISWAP_PAIR_SWAP_CALL_SELECTOR_32 = 0x022c0d9f00000000000000000000000000000000000000000000000000000000;
    // bytes4(keccak256("transferFrom(address,address,uint256)"))
    uint256 constant private TRANSFER_FROM_CALL_SELECTOR_32 = 0x23b872dd00000000000000000000000000000000000000000000000000000000;
    // bytes4(keccak256("allowance(address,address)"))
    uint256 constant private ALLOWANCE_CALL_SELECTOR_32 = 0xdd62ed3e00000000000000000000000000000000000000000000000000000000;
    // bytes4(keccak256("withdraw(uint256)"))
    uint256 constant private WETH_WITHDRAW_CALL_SELECTOR_32 = 0x2e1a7d4d00000000000000000000000000000000000000000000000000000000;
    // bytes4(keccak256("deposit()"))
    uint256 constant private WETH_DEPOSIT_CALL_SELECTOR_32 = 0xd0e30db000000000000000000000000000000000000000000000000000000000;
    // bytes4(keccak256("transfer(address,uint256)"))
    uint256 constant private ERC20_TRANSFER_CALL_SELECTOR_32 = 0xa9059cbb00000000000000000000000000000000000000000000000000000000;

    /// @dev Construct this contract.
    /// @param weth The WETH contract.
    /// @param allowanceTarget The AllowanceTarget contract.
    /// @param greedyTokensBloomFilter The bloom filter for greedy tokens.
    constructor(
        IEtherTokenV06 weth,
        IAllowanceTarget allowanceTarget,
        bytes32 greedyTokensBloomFilter
    ) public {
        WETH = weth;
        ALLOWANCE_TARGET = allowanceTarget;
        GREEDY_TOKENS_BLOOM_FILTER = greedyTokensBloomFilter;
    }

    /// @dev Initialize and register this feature.
    ///      Should be delegatecalled by `Migrate.migrate()`.
    /// @return success `LibMigrate.SUCCESS` on success.
    function migrate()
        external
        returns (bytes4 success)
    {
        _registerFeatureFunction(this.sellToUniswap.selector);
        return LibMigrate.MIGRATE_SUCCESS;
    }

    /// @dev Efficiently sell directly to uniswap/sushiswap.
    /// @param tokens Sell path.
    /// @param sellAmount of `tokens[0]` Amount to sell.
    /// @param minBuyAmount Minimum amount of `tokens[-1]` to buy.
    /// @param isSushi Use sushiswap if true.
    /// @return buyAmount Amount of `tokens[-1]` bought.
    function sellToUniswap(IERC20TokenV06[] calldata tokens, uint256 sellAmount, uint256 minBuyAmount, bool isSushi) external payable override returns (uint256 buyAmount) { require(tokens.length > 1, 'UniswapFeature/InvalidTokensLength'); for (uint256 i = 0; i < tokens.length - 1; i++) { IERC20TokenV06 sellToken = tokens[i]; IERC20TokenV06 buyToken = tokens[i + 1]; if (sellToken == IEtherTokenV06(WETH).WETH()) { // Handle WETH trade if sellToken is WETH } else { // Handle ERC20 trade if sellToken is an ERC20 token } // Perform the swap between sellToken and buyToken safely without allowing reentrancy attacks } require(buyAmount >= minBuyAmount, 'UniswapFeature/UnderBought'); }
}
