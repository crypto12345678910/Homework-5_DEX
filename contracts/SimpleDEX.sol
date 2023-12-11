// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./PriceConsumer.sol";
import "./interfaces/IErrors.sol";
import "./interfaces/ITreasury.sol";
import "./interfaces/IToken.sol";


contract SimpleDEX is Ownable, IErrors {

    address public token;
    address public externalTreasury;

    PriceConsumerV3 public ethUsdContract;
    uint256 public ethPriceDecimals;
    uint256 public ethPrice;

    event Bought(uint256 amount);
    event Sold(uint256 amount);

    constructor(address _token, address oracleEthUsdPrice) {
        token = _token;
        ethUsdContract = new PriceConsumerV3(oracleEthUsdPrice);
        ethPriceDecimals = ethUsdContract.getPriceDecimals();
    }

    receive() external payable {
        buyToken();
    }

    function setTreasury(address _treasury) external onlyOwner {
        externalTreasury = _treasury;
    }

    function treasuryMovs (address _to, uint256 _amount) internal {
        (bool sent, ) = payable(_to).call{value: _amount}("");
        if (!sent) {   
            revert ethNotSent();
        }
    }

    function buyToken() payable public {
        if (externalTreasury == address(0)) { 
            revert invalidTreasuryAddress();
        }
        uint256 amountToBuy = msg.value;
        //require(amountToBuy > 0, "You need to send some ether");
        if(amountToBuy == 0) {
            revert invalidAmount();
        }
        //uint256 dexBalance = IERC20(token).balanceOf(address(this));

        // getCLParameters();
        ethPrice = uint256(ethUsdContract.getLatestPrice());
        uint256 amountToSend = amountToBuy * ethPrice / (10 ** ethPriceDecimals);

        // (bool sent, ) = payable(externalTreasury).call{value; amountToBuy}("");
        // if (!sent) {
        //      revert ethNotSent();
        // }

        treasuryMovs (externalTreasury, amountToBuy);

        //require(amountToSend <= dexBalance, "Not enough tokens in the reserve");
        // token.transfer(msg.sender, amountToBuy);
        // SafeERC20.safeTransfer(IERC20(token), msg.sender, amountToSend);
        IToken(token).mint(amountToSend);

        emit Bought(amountToSend);
    }

    function sellToken(uint256 amount) public {
        require(amount > 0, "You need to sell at least some tokens");
        if(amount == 0) {
            revert invalidAmount();
        }
        if(IToken(token).balanceOf(msg.sender) < amount) {
            revert invalidUserBalance();
        }
        //uint256 allowance = IERC20(token).allowance(msg.sender, address(this));
        //require(allowance >= amount, "Check the token allowance");
        // token.transferFrom(msg.sender, address(this), amount);

        //getCLParameters();
        ethPrice = uint256(ethUsdContract.getLatestPrice());
        uint256 amountToSend = amount * (10 ** ethPriceDecimals) / ethPrice;

        //SafeERC20.safeTransferFrom(IERC20(token), msg.sender, address(this), amount);
        IToken(token).burn(msg.sender, amount);
        //ITreasury(externalTreasury).withdraw(amountToSend);

        //require(address(this).balance >= amountToSend, "Not enough ethers in the reserve");
        if(address(externalTreasury).balance < amountToSend) {
            revert notEnoughBalance();
        }
        //(bool sent, ) = payable(msg.sender).call{value: amountToSend}("");
        //if (!sent) {
        //    revert ethNotSent();
        //}
        treasuryMows(msg.sender, amountToSend);

        emit Sold(amount);
    }
}

