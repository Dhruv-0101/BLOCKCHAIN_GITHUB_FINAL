// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IUniswapV2Factory} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract uniswapV2Swap {
    IUniswapV2Factory uniswap_v2_sepolia_factory;
    IUniswapV2Router02 uniswap_v2_sepolia_router;
    address constant UNISWAP_V2_SEPOLIA_FACTORY = 0xF62c03E08ada871A0bEb309762E260a7a6a880E6;
    address constant UNISWAP_V2_SEPOLIA_ROUTER = 0xeE567Fe1712Faf6149d80dA1E6934E354124CfE3;

    event PairCreated(address indexed tokenA, address indexed tokenB);
    event LiquidityAdded(
        address indexed tokenA, address indexed tokenB, uint256 amountA, uint256 amountB, address indexed to
    );
    event LiquidityRemoved(
        address indexed tokenA, address indexed tokenB, uint256 amountA, uint256 amountB, address indexed to
    );

    constructor() {
        uniswap_v2_sepolia_factory = IUniswapV2Factory(UNISWAP_V2_SEPOLIA_FACTORY);
        uniswap_v2_sepolia_router = IUniswapV2Router02(UNISWAP_V2_SEPOLIA_ROUTER);
    }

    // first function to create a pair for TokenA and TokenB
    function createPair(address tokenA, address tokenB) external returns (address) {
        require(tokenA != address(0) && tokenB != address(0), "Invalid token address");
        require(tokenA != tokenB, "Tokens must be different");
        address pair = uniswap_v2_sepolia_factory.createPair(tokenA, tokenB);
        emit PairCreated(tokenA, tokenB);
        return pair;
    }

    // get the token pair address that we created
    function getPairAddress(address tokenA, address tokenB) external view returns (address) {
        require(tokenA != address(0) && tokenB != address(0), "Invalid token address");
        return uniswap_v2_sepolia_factory.getPair(tokenA, tokenB);
    }

    // add liquidity to the pair contract that we created
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB,
        address to,
        uint256 deadline
    ) external returns (uint256 amountAAdded, uint256 amountBAdded, uint256 liquidity) {
        require(tokenA != address(0) && tokenB != address(0), "Invalid token address");
        require(
            amountA > 0 && amountB > 0 && to != address(0),
            "Amounts must be greater than zero and recipient address must be valid"
        );
        require(deadline > block.timestamp, "Deadline must be in the future");
        address pair = uniswap_v2_sepolia_factory.getPair(tokenA, tokenB);
        require(pair != address(0), "Pair does not exist");
        // Transfer tokens to the contract
        // IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        // IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);
        // Approve the router to spend tokens
        IERC20(tokenA).approve(address(uniswap_v2_sepolia_router), amountA);
        IERC20(tokenB).approve(address(uniswap_v2_sepolia_router), amountB);
        // Add liquidity
        (uint256 _amountAAdded, uint256 _amountBAdded, uint256 _liquidity) = uniswap_v2_sepolia_router.addLiquidity(
            tokenA,
            tokenB,
            amountA,
            amountB,
            0, // Min amount A
            0, // Min amount B
            to,
            deadline
        );
        emit LiquidityAdded(tokenA, tokenB, _amountAAdded, _amountBAdded, to);
        return (_amountAAdded, _amountBAdded, _liquidity);
    }

    // function to remove liquidity from the pair contract
    function removeLiquidity(address tokenA, address tokenB, uint256 liquidity, address to, uint256 deadline)
        external
        returns (uint256 amountA, uint256 amountB)
    {
        require(tokenA != address(0) && tokenB != address(0), "Invalid token address");
        require(liquidity > 0 && to != address(0), "Liquidity and recipient address must be valid");
        require(deadline > block.timestamp, "Deadline must be in the future");

        address pair = uniswap_v2_sepolia_factory.getPair(tokenA, tokenB);
        require(pair != address(0), "Pair does not exist");

        IERC20(pair).transferFrom(msg.sender, address(this), liquidity);
        IERC20(pair).approve(address(uniswap_v2_sepolia_router), liquidity);

        (amountA, amountB) = uniswap_v2_sepolia_router.removeLiquidity(tokenA, tokenB, liquidity, 0, 0, to, deadline);
        emit LiquidityRemoved(tokenA, tokenB, amountA, amountB, to);
        return (amountA, amountB);
    }
    // function to swap tokens

    function swapTokens(
        address tokenA,
        address tokenB,
        uint256 amountIn,
        uint256 amountOutMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountOut) {
        require(tokenA != address(0) && tokenB != address(0), "Invalid token address");
        require(
            amountIn > 0 && to != address(0), "Amount must be greater than zero and recipient address must be valid"
        );
        require(deadline > block.timestamp, "Deadline must be in the future");
        address pair = uniswap_v2_sepolia_factory.getPair(tokenA, tokenB);
        require(pair != address(0), "Pair does not exist");
        // Approve the router to spend tokens\
        // trasfer tokens to the contract
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenA).approve(address(uniswap_v2_sepolia_router), amountIn);
        // Swap tokens
        address[] memory path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;
        uint256[] memory amounts =
            uniswap_v2_sepolia_router.swapExactTokensForTokens(amountIn, amountOutMin, path, to, deadline);
        amountOut = amounts[1];
        return amountOut;
    }
    // a/b b/c a a/b b/c path a,b, c

    // swap token for exact tokens
    function swapTokensForExact(
        address tokenA,
        address tokenB,
        uint256 amountOut,
        uint256 amountInMax,
        address to,
        uint256 deadline
    ) external returns (uint256 amountIn) {
        require(tokenA != address(0) && tokenB != address(0), "Invalid token address");
        require(
            amountOut > 0 && to != address(0), "Amount must be greater than zero and recipient address must be valid"
        );
        require(deadline > block.timestamp, "Deadline must be in the future");
        address pair = uniswap_v2_sepolia_factory.getPair(tokenA, tokenB);
        require(pair != address(0), "Pair does not exist");
        // Approve the router to spend tokens
        // Transfer tokens to the contract
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountInMax);
        IERC20(tokenB).approve(address(uniswap_v2_sepolia_router), amountOut);
        // Swap tokens
        address[] memory path = new address[](2);
        path[0] = tokenB;
        path[1] = tokenA;
        uint256[] memory amounts =
            uniswap_v2_sepolia_router.swapTokensForExactTokens(amountOut, amountInMax, path, to, deadline);
        amountIn = amounts[0];
        return amountIn;
    }
}
