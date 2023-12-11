// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./interfaces/IErrors.sol";
import "./interfaces/ITreasury.sol";

//error notSimpleDEX();
//error ethNotSent();


contract Treasury is IErrors, ITreasury {
    address public owner;
    address public simpleDexAddress;

    constructor(address simpleDEX) {
        if(simpleDEX == address(0)) {
            revert invalidAddress();
        }
        owner = msg.sender;
        simpleDexAddress = simpleDEX;
    }

    receive() payable external {}

    modifier onlySimpleDEX() {
        //require(msg.sender == simpleDexAddress, "not a simple DEX");
        if(msg.sender != simpleDexAddress){
            revert notSimpleDEX();
        }
        _;
    }

    function withdraw(uint256 amount) external onlySimpleDEX {
        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        if (!sent) {
            revert ethNotSent();
        }
    }
}