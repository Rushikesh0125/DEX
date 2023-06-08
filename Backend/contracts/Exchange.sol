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
    function addLiquidity(uint256 _amount) public payable returns(uint){
        uint liquidity;
        uint ethBal = address(this).balance;
        uint lpBalance = getReserve();
        ERC20 lp = ERC20(lpToken);

        /*initial liquidity is directly added without calculating the
        correct ratios of eth reserve and lp token reserve */
        if(lpBalance == 0){

            lp.transferFrom(msg.sender, address(this), _amount);

            liquidity = ethBal;

            _mint(msg.sender, liquidity);

        }else{
            /*If the reserve is not empty, intake any user supplied value for
            `Ether` and determine according to the ratio how many `Crypto Dev` tokens
            need to be supplied to prevent any large price impacts because of the additional
            liquidity */

            uint ethRes = ethBal - msg.value;

            uint lpAmount = (msg.value * lpBalance)/ethRes;

            require(lpAmount <= _amount, "Insufficient amount of lp tokens");

            lp.transferFrom(msg.sender, address(this), lpAmount);

            liquidity = (msg.value*totalSupply())/ethRes;

            _mint(msg.sender, liquidity);

        }
        return liquidity;

    }

    function removeLiquidity(uint _amount) public returns(uint, uint){
        require(_amount > 0, "amount should be greater than zero");
        uint ethRes = address(this).balance;
        uint _totalSupply = totalSupply();

        uint ethAmount = (ethRes * _amount)/_totalSupply;

        uint lpTokenAmount = (getReserve()*_amount)/_totalSupply;

        _burn(msg.sender, _amount);

        payable(msg.sender).transfer(ethAmount);

        ERC20(lpToken).transfer(msg.sender, lpTokenAmount);

        return (ethAmount, lpTokenAmount);
    }

    function getAmountOfTokens(uint256 inputAmount, uint256 inputReserve, uint256 outputReserve) public pure returns(uint256){
        require(inputReserve > 0 && outputReserve > 0, "Reserves not valid");
        uint256 inputAmountWithFees = inputAmount * 99;
        uint256 num = inputAmountWithFees * outputReserve;
        uint256 denum = (inputReserve*100)+inputAmountWithFees;
        return num/denum;
    }

    function ethToToken(uint _mintToken) public payable{
        uint256 tokenRes = getReserve();
        uint256 tokensBought = getAmountOfTokens(msg.value, address(this).balance - msg.value, tokenRes);

        require(tokensBought >= _mintToken, "insuffiecient output amount");

        ERC20(lpToken).transfer(msg.sender, tokensBought);
    }

    function TokenToEth(uint _tokenSold, uint _minEth) public{
        uint256 tokenRes = getReserve();

        uint256 ethBought = getAmountOfTokens(_tokenSold, tokenRes, address(this).balance);

        require(ethBought >= _minEth, "insufficient ouptut amount");

        ERC20(lpToken).transferFrom(msg.sender, address(this), _tokenSold);

        payable(msg.sender).transfer(ethBought);
    }

    


}