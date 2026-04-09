// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;
pragma abicoder v2;

import '@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import './BaseModule.sol';
import '../helpers/UniswapNFTHelper.sol';
import '../../interfaces/IPositionManager.sol';
import '../../interfaces/IUniswapAddressHolder.sol';
import '../../interfaces/actions/IClosePosition.sol';
import '../../interfaces/actions/ISwapToPositionRatio.sol';
import '../../interfaces/actions/IMint.sol';

///@title Idle Liquidity Module to manage liquidity for a user position
contract IdleLiquidityModule is BaseModule {
    ///@notice uniswap address holder
    IUniswapAddressHolder public uniswapAddressHolder;

    ///@notice assing the uniswap address holder to the contract
    ///@param _uniswapAddressHolder address of the uniswap address holder
    ///@param _registry address of the registry
    constructor(address _uniswapAddressHolder, address _registry) BaseModule(_registry) {
        uniswapAddressHolder = IUniswapAddressHolder(_uniswapAddressHolder);
    }

    ///@notice check if the position is in the range of the pools and return rebalance the position swapping the tokens
    ///@param tokenId tokenId of the position
    ///@param positionManager address of the position manager
    function rebalance(uint256 tokenId, IPositionManager positionManager)
        public
        onlyWhitelistedKeeper
        activeModule(address(positionManager), tokenId)
    {
        uint24 tickDistance = _checkDistanceFromRange(tokenId);
        (, bytes32 rebalanceDistance) = positionManager.getModuleInfo(tokenId, address(this));

        ///@dev rebalance only if the position's range is outside of the tick of the pool (tickDistance < 0) and the position is far enough from tick of the pool
        if (tickDistance > 0 && uint24(uint256(rebalanceDistance)) <= tickDistance) {
            (, , address token0, address token1, uint24 fee, , , , , , , ) = INonfungiblePositionManager(
                uniswapAddressHolder.nonfungiblePositionManagerAddress()
            ).positions(tokenId);

            ///@dev calc tickLower and tickUpper with the same delta as the position but with tick of the pool in center
            (int24 tickLower, int24 tickUpper) = _calcTick(tokenId, fee);

            ///@dev call closePositionAction
            (, uint256 amount0Closed, uint256 amount1Closed) = IClosePosition(address(positionManager)).closePosition(
                tokenId,
                false
            );

            ///@dev call swapToPositionAction to perform the swap
            (uint256 token0Swapped, uint256 token1Swapped) = ISwapToPositionRatio(address(positionManager))
                .swapToPositionRatio(
                    ISwapToPositionRatio.SwapToPositionInput(
                        token0,
                        token1,
                        fee,
                        amount0Closed,
                        amount1Closed,
                        tickLower,
                        tickUpper
                    )
                );

            ///@dev call mintAction
            IMint(address(positionManager)).mint(
                IMint.MintInput(token0, token1, fee, tickLower, tickUpper, token0Swapped - 10, token1Swapped - 10)
            );
        }
    }

    ///@notice checkDistance from ticklower tickupper from tick of the pools
    ///@param tokenId tokenId of the position
    ///@return int24 distance from ticklower tickupper from tick of the pools and return the minimum distance
    function _checkDistanceFromRange(uint256 tokenId) internal view returns (uint24) {
        (
            ,
            ,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            ,
            ,
            ,
            ,

        ) = INonfungiblePositionManager(uniswapAddressHolder.nonfungiblePositionManagerAddress()).positions(tokenId);

        IUniswapV3Pool pool = IUniswapV3Pool(
            UniswapNFTHelper._getPool(uniswapAddressHolder.uniswapV3FactoryAddress(), token0, token1, fee)
        );
        (, int24 tick, , , , , ) = pool.slot0();

        if (tick > tickUpper) {
            return uint24(tick - tickUpper);
        } else if (tick < tickLower) {
            return uint24(tickLower - tick);
        } else {
            return 0;
        }
    }

    ///@notice calc tickLower and tickUpper with the same delta as the position but with tick of the pool in center
    ///@param tokenId tokenId of the position
    ///@param fee fee of the position
    ///@return int24 tickLower
    ///@return int24 tickUpper
        ///@notice calc tickLower and tickUpper with the same delta as the position but with tick of the pool in center
    ///@param tokenId tokenId of the position
    ///@param fee fee of the position
    ///@return int24 tickLower
    ///@return int24 tickUpper
        ///@notice calc tickLower and tickUpper with the same delta as the position but with tick of the pool in center
    ///@param tokenId tokenId of the position
    ///@param fee fee of the position
    ///@return int24 tickLower
    ///@return int24 tickUpper
    function _calcTick(uint256 tokenId, uint24 fee) internal view returns (int24, int24) {
        (, , , , , int24 tickLower, int24 tickUpper, , , , , ) = INonfungiblePositionManager(
            uniswapAddressHolder.nonfungiblePositionManagerAddress()
        ).positions(tokenId);

        // Use safe arithmetic for tickDelta calculation
        int24 tickDelta;
        if (tickUpper >= tickLower) {
            tickDelta = tickUpper - tickLower;
        } else {
            // This shouldn't happen in valid positions, but handle gracefully
            revert("Invalid tick range");
        }

        IUniswapV3Pool pool = IUniswapV3Pool(
            UniswapNFTHelper._getPoolFromTokenId(
                tokenId,
                INonfungiblePositionManager(uniswapAddressHolder.nonfungiblePositionManagerAddress()),
                uniswapAddressHolder.uniswapV3FactoryAddress()
            )
        );

        (, int24 tick, , , , , ) = pool.slot0();
        
        // Calculate tickSpacing safely
        int24 tickSpacing = int24(fee) / 50;
        require(tickSpacing > 0, "Invalid tick spacing");
        
        // Calculate new tickLower with overflow protection
        int24 newTickLower;
        int24 newTickUpper;
        
        // Calculate (tick - tickDelta) safely checking for underflow
        if (tick < tickDelta) {
            // Underflow would occur, use a different approach
            // For Uniswap V3, ticks have minimum limits, so we use reasonable bounds
            newTickLower = (tick - tickDelta + tickSpacing - 1) / tickSpacing * tickSpacing;
        } else {
            newTickLower = (tick - tickDelta) / tickSpacing * tickSpacing;
        }
        
        // Calculate (tick + tickDelta) safely checking for overflow
        // Maximum tick in Uniswap V3 is 887272, so check against this limit
        if (tick > 887272 - tickDelta) {
            // Would overflow maximum tick, cap at maximum valid tick
            int24 maxTick = 887272;
            newTickUpper = (maxTick / tickSpacing) * tickSpacing;
        } else {
            newTickUpper = (tick + tickDelta) / tickSpacing * tickSpacing;
        }
        
        // Ensure tickLower < tickUpper as required by Uniswap
        require(newTickLower < newTickUpper, "Invalid tick calculation");
        
        // Ensure ticks are within valid Uniswap V3 range (-887272 to 887272)
        require(newTickLower >= -887272 && newTickUpper <= 887272, "Ticks out of valid range");
        
        return (newTickLower, newTickUpper);
    }
}
