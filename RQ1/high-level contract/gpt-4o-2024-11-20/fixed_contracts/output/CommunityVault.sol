// SWC-103-Floating Pragma: L2
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CommunityVault is Ownable {

    IERC20 private _bond;

    constructor (address bond) public {
        _bond = IERC20(bond);
    }

    event SetAllowance(address indexed caller, address indexed spender, uint256 amount);

    pragma solidity ^0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract CommunityVault is Ownable, ReentrancyGuard {

    IERC20 private _bond;

    constructor (address bond) public {
        _bond = IERC20(bond);
    }

    event SetAllowance(address indexed caller, address indexed spender, uint256 amount);

    function setAllowance(address spender, uint256 amount) public onlyOwner nonReentrant {
        _bond.approve(spender, amount);
        emit SetAllowance(msg.sender, spender, amount);
    }
}
}
