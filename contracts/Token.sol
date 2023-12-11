// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IErrors.sol";
import "./interfaces/IToken.sol";


contract Token is ERC20, Ownable, IErrors, IToken {

    address public minterAddress;

    constructor(string memory _tokenName, 
            string memory _tokenSymbol,
            uint256 _supply) ERC20(_tokenName, _tokenSymbol) {
        _mint(msg.sender, _supply*(1e18));
    }

    modifier onlyMinter() {
        if(msg.sender != minterAddress) {
            revert notMinter();
        }
        _;
    }

    function setMinter(address minter) external onlyOwner {
        if(minter == address(0)) {
            revert invalidAddress();
        }
        minterAddress = minter;
    }

    function mint(uint256 _amount) external onlyMinter {
        _mint(msg.sender, _amount*(1e18));
    }
    
    function burn(uint256 _from) external onlyMinter {
        _burn(msg.sender, _amount*(1e18));
    }
}
