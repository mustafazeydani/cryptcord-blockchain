// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CryptcordTest is Ownable {
    constructor() Ownable(msg.sender) {}

    // Errors
    error InsufficientBalance(uint256 balance, uint256 withdrawAmount);
    error TransferFailed(
        address tokenAddress,
        address from,
        address to,
        uint256 value
    );

    // Events
    event Transfer(address indexed erc20, address indexed from, address indexed to, uint256 value);

    function calculateFee(uint256 number) internal pure returns (uint256) {
        uint256 scaleFactor = 1000;
        uint256 feePercentage = 75; // Represents 7.5%
        return (number * feePercentage) / scaleFactor;
    }

    function calculateTransferAmount(uint256 number)
        internal
        pure
        returns (uint256)
    {
        uint256 scaleFactor = 1000;
        uint256 transferPercentage = 925; // Represents 92.5%
        return (number * transferPercentage) / scaleFactor;
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
            revert InsufficientBalance({
                balance: fromBalance,
                withdrawAmount: amount
            });
        }

        // Calculate the amounts
        uint256 fee = calculateFee(amount);
        uint256 transferAmount = calculateTransferAmount(amount);

        // Transfer the fee to the owner
        if (!token.transferFrom(from, owner(), fee)) {
            revert TransferFailed({
                tokenAddress: erc20,
                from: from,
                to: owner(),
                value: fee
            });
        }

        // Transfer the remaining amount to the destination address
        if (!token.transferFrom(from, to, transferAmount)) {
            revert TransferFailed({
                tokenAddress: erc20,
                from: from,
                to: to,
                value: transferAmount
            });
        }

        // Event
        emit Transfer(erc20, from, to, transferAmount);
    }
}
