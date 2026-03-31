// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenA is ERC20 {
    constructor() ERC20("Token A", "TKNA") {
        _mint(msg.sender, 1_000_000 * 10 ** 18); // Mint 1,000,000 tokens (18 decimals)
    }
}
//TokenA = 0x9F7ca69ED4118342beBeB81734e009029a85A0Ab
//TokenB = 0xFA79488711209c982e62dBB4Bc30806497A85994