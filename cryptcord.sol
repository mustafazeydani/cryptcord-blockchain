// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Cryptcord is Ownable {
    constructor() Ownable(msg.sender) {}

    // Errors
    error InsufficientBalance(uint256 balance, uint256 withdrawAmount);
    error TransferFailed(address tokenAddress, address from, address to, uint256 value);

    function approveTokens(address erc20, address spender, uint256 amount) public {
        IERC20(erc20).approve(spender, amount);
    }
    
    function transferTokens(
        address erc20,
        uint256 amount,
        address from,
        address to
    ) public {
        IERC20 token = IERC20(erc20);
        uint256 fromBalance = token.balanceOf(from);

         // Check if sender has enough balance
        if (fromBalance < amount) {
            revert InsufficientBalance({balance: fromBalance, withdrawAmount: amount});
        }

         // Calculate the amounts
        uint256 fee = (amount * 75) / 1000;  // 7.5% of the amount
        uint256 transferAmount = amount - fee;  // 92.5% of the amount

         // Transfer the fee to the owner
        if (!token.transferFrom(from, owner(), fee)) {
            revert TransferFailed({tokenAddress: erc20, from: from, to: owner(), value: fee});
        }

         // Transfer the remaining amount to the destination address
        if (!token.transferFrom(from, to, transferAmount)) {
            revert TransferFailed({tokenAddress: erc20, from: from, to: to, value: transferAmount});
        }
    }
}