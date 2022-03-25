// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SimpleToken is ERC20 {
    constructor() ERC20("SimpleToken", "Simp") {
        _mint(msg.sender, 10);
        approve(msg.sender, balanceOf(msg.sender));
    }
}
