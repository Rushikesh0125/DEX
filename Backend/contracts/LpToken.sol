// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LpToken is ERC20 {
    
    constructor() ERC20("LpToken", "LPT") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}