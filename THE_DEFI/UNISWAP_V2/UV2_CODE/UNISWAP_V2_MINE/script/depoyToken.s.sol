//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {TokenA} from "../src/TokenA.sol";
import {TokenB} from "../src/TokenB.sol";
import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

contract DeployTokenA is Script {
    TokenA public tokenA;
    TokenB public tokenB;

    function run() external {
        vm.startBroadcast();
        tokenA = new TokenA();
        tokenB = new TokenB();
        vm.stopBroadcast();

        console.log("TokenA deployed at:", address(tokenA));
        console.log("TokenB deployed at:", address(tokenB));
    }
}
