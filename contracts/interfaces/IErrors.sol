// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IErrors {
    error notSimpleDEX();
    error ethNotSent();
    error notMinter();
    error notEnoughBalance();
    error invalidAddress();
    error invalidTreasuryAddress();
    error invalidAmount();
    error invalidUserBalance();
}