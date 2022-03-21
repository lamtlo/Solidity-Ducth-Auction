// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SimpleToken is ERC20 {
    constructor() public ERC20("SimpleToken", "Simp") {
        _mint(msg.sender, 10);
        approve(msg.sender, balanceOf(msg.sender));
    }
}