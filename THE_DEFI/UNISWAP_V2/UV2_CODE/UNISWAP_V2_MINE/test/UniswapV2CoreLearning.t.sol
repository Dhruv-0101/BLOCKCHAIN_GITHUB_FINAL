// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/UniswapV2CoreLearning.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/*
====================================================
TEST TOKENS (Apple 🍎 & Orange 🍊)
====================================================
*/

contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1_000_000 ether);
    }
}

contract UniswapV2CoreLearningTest is Test {
    UniswapV2CoreLearning uni;

    MockERC20 apple;
    MockERC20 orange;

    address user = address(1);

    function setUp() public {
        vm.startPrank(user);

        // deploy tokens
        apple = new MockERC20("Apple", "APL");
        orange = new MockERC20("Orange", "ORG");

        // deploy Uniswap helper
        uni = new UniswapV2CoreLearning();

        // fund user with ETH
        vm.deal(user, 100 ether);

        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                        CREATE PAIR
    //////////////////////////////////////////////////////////////*/

    function testCreatePair() public {
        vm.startPrank(user);

        address pair = uni.createPair(address(apple), address(orange));

        assertTrue(pair != address(0));

        vm.stopPrank();
    }

    function testGetPair() public {
        vm.startPrank(user);

        address pair1 = uni.createPair(address(apple), address(orange));
        address pair2 = uni.getPair(address(apple), address(orange));

        assertEq(pair1, pair2);

        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                        ADD LIQUIDITY
    //////////////////////////////////////////////////////////////*/

    function testAddLiquidityERC20() public {
        vm.startPrank(user);

        uni.createPair(address(apple), address(orange));

        apple.approve(address(uni), 100 ether);
        orange.approve(address(uni), 200 ether);

        (uint a, uint o, uint lp) = uni.addLiquidityERC20(
            address(apple),
            address(orange),
            100 ether,
            200 ether,
            user,
            block.timestamp + 1 hours
        );

        assertEq(a, 100 ether);
        assertEq(o, 200 ether);
        assertTrue(lp > 0);

        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                        REMOVE LIQUIDITY
    //////////////////////////////////////////////////////////////*/

    function testRemoveLiquidityERC20() public {
        vm.startPrank(user);

        uni.createPair(address(apple), address(orange));

        apple.approve(address(uni), 100 ether);
        orange.approve(address(uni), 200 ether);

        (, , uint lp) = uni.addLiquidityERC20(
            address(apple),
            address(orange),
            100 ether,
            200 ether,
            user,
            block.timestamp + 1 hours
        );

        address pair = uni.getPair(address(apple), address(orange));

        IERC20(pair).approve(address(uni), lp);

        (uint appleOut, uint orangeOut) = uni.removeLiquidityERC20(
            address(apple),
            address(orange),
            lp,
            user,
            block.timestamp + 1 hours
        );

        assertTrue(appleOut > 0);
        assertTrue(orangeOut > 0);

        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                        SWAP EXACT TOKENS
    //////////////////////////////////////////////////////////////*/

    function testSwapExactTokens() public {
        vm.startPrank(user);

        uni.createPair(address(apple), address(orange));

        apple.approve(address(uni), 100 ether);
        orange.approve(address(uni), 200 ether);

        uni.addLiquidityERC20(
            address(apple),
            address(orange),
            100 ether,
            200 ether,
            user,
            block.timestamp + 1 hours
        );

        apple.approve(address(uni), 10 ether);

        uint orangeOut = uni.swapExactTokens(
            address(apple),
            address(orange),
            10 ether,
            1 ether,
            user,
            block.timestamp + 1 hours
        );

        assertTrue(orangeOut > 0);

        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                    SWAP TOKENS FOR EXACT
    //////////////////////////////////////////////////////////////*/

    function testSwapTokensForExact() public {
        vm.startPrank(user);

        uni.createPair(address(apple), address(orange));

        apple.approve(address(uni), 100 ether);
        orange.approve(address(uni), 200 ether);

        uni.addLiquidityERC20(
            address(apple),
            address(orange),
            100 ether,
            200 ether,
            user,
            block.timestamp + 1 hours
        );

        apple.approve(address(uni), 20 ether);

        uint appleUsed = uni.swapTokensForExact(
            address(apple),
            address(orange),
            10 ether,
            20 ether,
            user,
            block.timestamp + 1 hours
        );

        assertTrue(appleUsed > 0);
        assertTrue(appleUsed <= 20 ether);

        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                    SWAP EXACT ETH → TOKEN
    //////////////////////////////////////////////////////////////*/

    function testSwapExactETHForTokens() public {
        vm.startPrank(user);

        uni.createPair(address(apple), uni.router().WETH());

        apple.approve(address(uni), 1000 ether);

        uni.addLiquidityERC20(
            address(apple),
            uni.router().WETH(),
            1000 ether,
            10 ether,
            user,
            block.timestamp + 1 hours
        );

        uint appleOut = uni.swapExactETHForTokens{value: 1 ether}(
            address(apple),
            1 ether,
            user,
            block.timestamp + 1 hours
        );

        assertTrue(appleOut > 0);

        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                    SWAP EXACT TOKEN → ETH
    //////////////////////////////////////////////////////////////*/

    function testSwapExactTokensForETH() public {
        vm.startPrank(user);

        uni.createPair(address(apple), uni.router().WETH());

        apple.approve(address(uni), 1000 ether);

        uni.addLiquidityERC20(
            address(apple),
            uni.router().WETH(),
            1000 ether,
            10 ether,
            user,
            block.timestamp + 1 hours
        );

        apple.approve(address(uni), 100 ether);

        uint ethOut = uni.swapExactTokensForETH(
            address(apple),
            100 ether,
            0.1 ether,
            user,
            block.timestamp + 1 hours
        );

        assertTrue(ethOut > 0);

        vm.stopPrank();
    }
}
