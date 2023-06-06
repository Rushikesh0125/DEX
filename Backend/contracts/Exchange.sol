// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20{

    address public lpToken;

    //constructor accepts the token address for liquidity provider token as argument
    constructor(address token_address) ERC20("LP tokens", "LPT"){
        require(token_address != address(0), "You can't pass a null token address");
        lpToken = token_address;
    }

    //this function returns the lptoken liquidity amount present in exchange contract
    function getReserve() public view returns (uint256) {
        return ERC20(lpToken).balanceOf(address(this));
    }

    //Function to add liquidity to contract
    function addLiquidity(uint256 amount) public payable returns(uint){
        uint liquidity;
        uint ethBal = address(this).balance;
        uint lpBalance = getReserve();
        ERC20 lp = ERC20(lpToken);

        /*initial liquidity is directly added without calculating the
        correct ratios of eth reserve and lp token reserve */
        if(lpBalance == 0){

            lp.transferFrom(msg.sender, address(this), amount);

            liquidity = ethBal;

            _mint(msg.sender, liquidity);

        }else{
            /*If the reserve is not empty, intake any user supplied value for
            `Ether` and determine according to the ratio how many `Crypto Dev` tokens
            need to be supplied to prevent any large price impacts because of the additional
            liquidity */

            uint ethRes = ethBal - msg.value;

            uint lpAmount = (msg.value * lpBalance)/ethRes;

            require(lpAmount <= amount, "Insufficient amount of lp tokens");

            lp.transferFrom(msg.sender, address(this), lpAmount);

            liquidity = (msg.value*totalSupply())/ethRes;

            _mint(msg.sender, liquidity);

        }

    }

    


}