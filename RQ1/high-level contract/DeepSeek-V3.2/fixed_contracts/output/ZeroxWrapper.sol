// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "../../utils/SafeERC20.sol";
import "../../DS/DSMath.sol";
import "../../auth/AdminAuth.sol";
import "../DFSExchangeHelper.sol";
import "../../interfaces/exchange/IOffchainWrapper.sol";

contract ZeroxWrapper is IOffchainWrapper, DFSExchangeHelper, AdminAuth, DSMath {

    using TokenUtils for address;

    string public constant ERR_SRC_AMOUNT = "Not enough funds";
    string public constant ERR_PROTOCOL_FEE = "Not enough eth for protcol fee";
    string public constant ERR_TOKENS_SWAPED_ZERO = "Order success but amount 0";

    using SafeERC20 for IERC20;

    /// @notice Takes order from 0x and returns bool indicating if it is successful
    /// @param _exData Exchange data
    /// @param _type Action type (buy or sell)
        /// @notice Takes order from 0x and returns bool indicating if it is successful
    /// @param _exData Exchange data
    /// @param _type Action type (buy or sell)
        /// @notice Takes order from 0x and returns bool indicating if it is successful
    /// @param _exData Exchange data
    /// @param _type Action type (buy or sell)
    function takeOrder(
        ExchangeData memory _exData,
        ExchangeActionType _type
    ) override public payable returns (bool success, uint256) {
        // check that contract have enough balance for exchange and protocol fee
        require(_exData.srcAddr.getBalance(address(this)) >= _exData.srcAmount, ERR_SRC_AMOUNT);
        require(TokenUtils.ETH_ADDR.getBalance(address(this)) >= _exData.offchainData.protocolFee, ERR_PROTOCOL_FEE);

        /// @dev 0x always uses max approve in v1, so we approve the exact amount we want to sell
        /// @dev safeApprove is modified to always first set approval to 0, then to exact amount
        if (_type == ExchangeActionType.SELL) {
            IERC20(_exData.srcAddr).safeApprove(_exData.offchainData.allowanceTarget, _exData.srcAmount);
        } else {
            // Using SafeMath operations to prevent overflow/underflow
            // Added explicit type casting and overflow checks
            uint256 price = _exData.offchainData.price;
            require(price > 0, "Price cannot be zero");
            
            uint256 srcAmount = wdiv(_exData.destAmount, price);
            // Check for overflow before adding 1
            require(srcAmount < type(uint256).max, "Overflow in srcAmount calculation");
            srcAmount = srcAmount + 1; // + 1 so we round up
            
            IERC20(_exData.srcAddr).safeApprove(_exData.offchainData.allowanceTarget, srcAmount);
        }
        
        uint256 tokensBefore = _exData.destAddr.getBalance(address(this));
        (success, ) = _exData.offchainData.exchangeAddr.call{value: _exData.offchainData.protocolFee}(_exData.offchainData.callData);
        uint256 tokensSwaped = 0;

        if (success) {
            // Using SafeMath subtraction to prevent underflow
            uint256 tokensAfter = _exData.destAddr.getBalance(address(this));
            require(tokensAfter >= tokensBefore, "Balance underflow detected");
            tokensSwaped = tokensAfter - tokensBefore;
            require(tokensSwaped > 0, ERR_TOKENS_SWAPED_ZERO);
        }

        // returns all funds from src addr, dest addr and eth funds (protocol fee leftovers)
        sendLeftover(_exData.srcAddr, _exData.destAddr, msg.sender);

        return (success, tokensSwaped);
    }

    // solhint-disable-next-line no-empty-blocks
    receive() external virtual payable {}
}