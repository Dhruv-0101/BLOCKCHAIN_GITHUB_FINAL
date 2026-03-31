// pragma solidity ^0.8.24;
// pragma abicoder v2;

// // import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
// import "lib\swap-router-contracts\contracts\interfaces\IV3SwapRouter.sol";
// import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
// import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
// import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
// import "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

// // ERC20/ERC20
// // Native/ERC20 => ETH =>  WETH

// contract SimpleSwap is IERC721Receiver {
//     event PoolCreated(address indexed tokenA, address indexed tokenB, uint24 indexed fee, address pool);
//     event PoolInitialized(address indexed pool, uint160 sqrtPriceX96);

//     IV3SwapRouter public immutable swapRouter = IV3SwapRouter(0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E);
//     uint24 public constant feeTier = 3000;
//     address public immutable token0;
//     address public immutable token1;

//     IUniswapV3Factory public immutable iUniswapV3Factory = IUniswapV3Factory(0x0227628f3F023bb0B980b67D528571c95c6DaC1c);
//     INonfungiblePositionManager public immutable nonfungiblePositionManager =
//         INonfungiblePositionManager(0x1238536071E1c677A632429e3655c799b22cDA52);

//     struct Deposit {
//         address owner;
//         uint128 liquidity;
//         address token0;
//         address token1;
//     }

//     mapping(uint256 => Deposit) public deposits;

//     constructor(address _token0, address _token1) {
//         require(_token0 != address(0) && _token1 != address(0), "Invalid token addresses");
//         token0 = _token0;
//         token1 = _token1;
//     }

//     // Create pool and initialize it if it doesn't exist
//     function createAndInitializePoolIfNecessary(address tokenA, address tokenB, uint24 fee, uint160 sqrtPriceX96)
//         external
//         returns (address pool)
//     {
//         pool = iUniswapV3Factory.getPool(tokenA, tokenB, fee);

//         if (pool == address(0)) {
//             pool = iUniswapV3Factory.createPool(tokenA, tokenB, fee);
//             emit PoolCreated(tokenA, tokenB, fee, pool);
//         }

//         // Check if pool needs initialization
//         (uint160 currentSqrtPriceX96,,,,,,) = IUniswapV3Pool(pool).slot0();

//         if (currentSqrtPriceX96 == 0) {
//             IUniswapV3Pool(pool).initialize(sqrtPriceX96); // a/b 1:10
//             emit PoolInitialized(pool, sqrtPriceX96);
//         }
//         require(pool != address(0), "Pool creation failed");
//         return pool;
//     }

//     // Helper function to calculate sqrtPriceX96 for a 1:10 ratio (1 token0 = 10 token1)
//     function getSqrtPriceX96For1to10Ratio() public pure returns (uint160) {
//         // For a 1:10 ratio, price = 10
//         // sqrtPrice = sqrt(10) ≈ 3.16227766
//         // sqrtPriceX96 = sqrtPrice * 2^96
//         return 250541448375047931186413801569; // This represents sqrt(10) * 2^96
//     }

//     // Helper function to get current tick from pool
//     function getCurrentTick() external view returns (int24) {
//         address poolAddress = iUniswapV3Factory.getPool(token0, token1, feeTier);
//         require(poolAddress != address(0), "Pool does not exist");

//         (, int24 tick,,,,,) = IUniswapV3Pool(poolAddress).slot0();
//         return tick;
//     }

//     // Helper function to calculate tick range around current price
//     function getTickRangeAroundCurrent(int24 tickDistance) external view returns (int24 lowerTick, int24 upperTick) {
//         int24 currentTick = this.getCurrentTick();
//         int24 tickSpacing = 60; // For 0.3% fee tier

//         lowerTick = ((currentTick - tickDistance) / tickSpacing) * tickSpacing;
//         upperTick = ((currentTick + tickDistance) / tickSpacing) * tickSpacing;
//     }

//     // create pool if it does not exist (keeping original function for compatibility)
//     function createPoolIfNotExists(address tokenA, address tokenB, uint24 fee) external returns (address) {
//         address pool = iUniswapV3Factory.createPool(tokenA, tokenB, fee);
//         require(pool != address(0), "Pool creation failed");
//         emit PoolCreated(tokenA, tokenB, fee, pool);
//         return pool;
//     }

//     // get the pool address for a given pair of tokens and fee
//     function getPool(address tokenA, address tokenB, uint24 fee) external view returns (address) {
//         address pool = iUniswapV3Factory.getPool(tokenA, tokenB, fee);
//         require(pool != address(0), "Pool does not exist");
//         return pool;
//     }

//     function onERC721Received(address operator, address, uint256 tokenId, bytes calldata)
//         external
//         override
//         returns (bytes4)
//     {
//         // get position information
//         _createDeposit(operator, tokenId);
//         return this.onERC721Received.selector;
//     }

//     function _createDeposit(address owner, uint256 tokenId) internal {
//         (,, address posToken0, address posToken1,,,, uint128 liquidity,,,,) =
//             nonfungiblePositionManager.positions(tokenId);

//         // set the owner and data for position
//         // operator is msg.sender
//         deposits[tokenId] = Deposit({owner: owner, liquidity: liquidity, token0: posToken0, token1: posToken1});
//     }

//     // 1500 <=> 1800.
//     // add liquidity
//     function mintNewPosition(int24 _lowerTick, int24 _upperTick)
//         external
//         returns (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1)
//     {
//         // Check if pool exists and is initialized
//         address poolAddress = iUniswapV3Factory.getPool(token0, token1, feeTier);
//         require(poolAddress != address(0), "Pool does not exist");

//         (uint160 sqrtPriceX96,,,,,,) = IUniswapV3Pool(poolAddress).slot0();
//         require(sqrtPriceX96 > 0, "Pool not initialized");

//         uint256 amount0ToMint = 100 * 10 ** 18;
//         uint256 amount1ToMint = 1000 * 10 ** 18;

//         // Approve the position manager
//         TransferHelper.safeApprove(token0, address(nonfungiblePositionManager), amount0ToMint);
//         TransferHelper.safeApprove(token1, address(nonfungiblePositionManager), amount1ToMint);
//         // eth/usdc => 1:2000.  1600:1800
//         INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
//             token0: token0,
//             token1: token1,
//             fee: feeTier,
//             tickLower: _lowerTick,
//             tickUpper: _upperTick,
//             amount0Desired: amount0ToMint,
//             amount1Desired: amount1ToMint,
//             amount0Min: 0,
//             amount1Min: 0,
//             recipient: address(this),
//             deadline: block.timestamp
//         });

//         (tokenId, liquidity, amount0, amount1) = nonfungiblePositionManager.mint(params);
//         _createDeposit(msg.sender, tokenId);

//         // Remove allowance and refund in both assets
//         if (amount0 < amount0ToMint) {
//             TransferHelper.safeApprove(token0, address(nonfungiblePositionManager), 0);
//             uint256 refund0 = amount0ToMint - amount0;
//             TransferHelper.safeTransfer(token0, msg.sender, refund0);
//         }

//         if (amount1 < amount1ToMint) {
//             TransferHelper.safeApprove(token1, address(nonfungiblePositionManager), 0);
//             uint256 refund1 = amount1ToMint - amount1;
//             TransferHelper.safeTransfer(token1, msg.sender, refund1);
//         }
//     }
//     // Fixed version of increaseLiquidityCurrentRange function for SimpleSwap contract
//     // Replace the existing function in your contract with this one:

//     /// @notice Increases liquidity in the current range
//     /// @dev Pool must be initialized already to add liquidity
//     /// @param tokenId The id of the erc721 token
//     /// @param amountAdd0 The amount to add of token0
//     /// @param amountAdd1 The amount to add of token1
//     function increaseLiquidityCurrentRange(uint256 tokenId, uint256 amountAdd0, uint256 amountAdd1)
//         external
//         returns (uint128 liquidity, uint256 amount0, uint256 amount1)
//     {
//         // IMPORTANT: Approve the position manager to spend tokens
//         TransferHelper.safeApprove(token0, address(nonfungiblePositionManager), amountAdd0);
//         TransferHelper.safeApprove(token1, address(nonfungiblePositionManager), amountAdd1);

//         INonfungiblePositionManager.IncreaseLiquidityParams memory params = INonfungiblePositionManager
//             .IncreaseLiquidityParams({
//             tokenId: tokenId,
//             amount0Desired: amountAdd0,
//             amount1Desired: amountAdd1,
//             amount0Min: 0,
//             amount1Min: 0,
//             deadline: block.timestamp
//         });

//         (liquidity, amount0, amount1) = nonfungiblePositionManager.increaseLiquidity(params);

//         // Update the deposit struct liquidity (this was also missing)
//         deposits[tokenId].liquidity += liquidity;

//         // Clean up approvals and refund unused tokens
//         if (amount0 < amountAdd0) {
//             TransferHelper.safeApprove(token0, address(nonfungiblePositionManager), 0);
//             uint256 refund0 = amountAdd0 - amount0;
//             TransferHelper.safeTransfer(token0, msg.sender, refund0);
//         }

//         if (amount1 < amountAdd1) {
//             TransferHelper.safeApprove(token1, address(nonfungiblePositionManager), 0);
//             uint256 refund1 = amountAdd1 - amount1;
//             TransferHelper.safeTransfer(token1, msg.sender, refund1);
//         }
//     }

//     /// @notice A function that decreases the current liquidity by half. An example to show how to call the `decreaseLiquidity` function defined in periphery.
//     /// @param tokenId The id of the erc721 token
//     /// @return amount0 The amount received back in token0
//     /// @return amount1 The amount returned back in token1
//     function decreaseLiquidityInHalf(uint256 tokenId) external returns (uint256 amount0, uint256 amount1) {
//         // caller must be the owner of the NFT
//         require(msg.sender == deposits[tokenId].owner, "Not the owner");
//         // get liquidity data for tokenId
//         uint128 liquidity = deposits[tokenId].liquidity;
//         uint128 halfLiquidity = liquidity / 2;

//         // amount0Min and amount1Min are price slippage checks
//         // if the amount received after burning is not greater than these minimums, transaction will fail
//         INonfungiblePositionManager.DecreaseLiquidityParams memory params = INonfungiblePositionManager
//             .DecreaseLiquidityParams({
//             tokenId: tokenId,
//             liquidity: halfLiquidity,
//             amount0Min: 0,
//             amount1Min: 0,
//             deadline: block.timestamp
//         });

//         nonfungiblePositionManager.decreaseLiquidity(params);

//         (amount0, amount1) = nonfungiblePositionManager.collect(
//             INonfungiblePositionManager.CollectParams({
//                 tokenId: tokenId,
//                 recipient: address(this),
//                 amount0Max: type(uint128).max,
//                 amount1Max: type(uint128).max
//             })
//         );

//         //send liquidity back to owner
//         _sendToOwner(tokenId, amount0, amount1);
//     }

//     /// @notice Transfers funds to owner of NFT
//     /// @param tokenId The id of the erc721
//     /// @param amount0 The amount of token0
//     /// @param amount1 The amount of token1
//     function _sendToOwner(uint256 tokenId, uint256 amount0, uint256 amount1) internal {
//         // get owner of contract
//         address owner = deposits[tokenId].owner;

//         address tokenA = deposits[tokenId].token0;
//         address tokenB = deposits[tokenId].token1;
//         // send collected fees to owner
//         TransferHelper.safeTransfer(tokenA, owner, amount0);
//         TransferHelper.safeTransfer(tokenB, owner, amount1);
//     }

//     /// @notice swapExactInputSingle swaps a fixed amount of DAI for a maximum possible amount of WETH9
//     /// using the DAI/WETH9 0.3% pool by calling `exactInputSingle` in the swap router.
//     /// @dev The calling address must approve this contract to spend at least `amountIn` worth of its DAI for this function to succeed.
//     /// @param amountIn The exact amount of DAI that will be swapped for WETH9.
//     /// @return amountOut The amount of WETH9 received.

//     // a/b  a amountIn => b amountOut
//     function swapExactInputSingle(uint256 amountIn) external returns (uint256 amountOut) {
//         // Transfer token0 to this contract
//         TransferHelper.safeTransferFrom(token0, msg.sender, address(this), amountIn);

//         // Approve the router to spend token0
//         TransferHelper.safeApprove(token0, address(swapRouter), amountIn);

//         IV3SwapRouter.ExactInputSingleParams memory params = IV3SwapRouter.ExactInputSingleParams({
//             tokenIn: token0,
//             tokenOut: token1,
//             fee: feeTier,
//             recipient: msg.sender,
//             amountIn: amountIn,
//             amountOutMinimum: 0, // Set to 0 for simplicity, but should be set based on slippage tolerance
//             sqrtPriceLimitX96: 0
//         });

//         amountOut = swapRouter.exactInputSingle(params);
//     }
//     /// @notice swapExactOutputSingle swaps a minimum possible amount of DAI for a fixed amount of WETH.
//     /// @dev The calling address must approve this contract to spend its DAI for this function to succeed. As the amount of input DAI is variable,
//     /// the calling address will need to approve for a slightly higher amount, anticipating some variance.
//     /// @param amountOut The exact amount of WETH9 to receive from the swap.
//     /// @param amountInMaximum The amount of DAI we are willing to spend to receive the specified amount of WETH9.
//     /// @return amountIn The amount of DAI actually spent in the swap.

//     function swapExactOutputSingle(uint256 amountOut, uint256 amountInMaximum) external returns (uint256 amountIn) {
//         // Transfer the specified amount of DAI to this contract.
//         TransferHelper.safeTransferFrom(token0, msg.sender, address(this), amountInMaximum);

//         // Approve the router to spend the specified `amountInMaximum` of DAI.
//         // In production, you should choose the maximum amount to spend based on oracles or other data sources to achieve a better swap.
//         TransferHelper.safeApprove(token0, address(swapRouter), amountInMaximum);

//         IV3SwapRouter.ExactOutputSingleParams memory params = IV3SwapRouter.ExactOutputSingleParams({
//             tokenIn: token0,
//             tokenOut: token1,
//             fee: feeTier,
//             recipient: msg.sender,
//             amountOut: amountOut,
//             amountInMaximum: amountInMaximum,
//             sqrtPriceLimitX96: 0
//         });

//         // Executes the swap returning the amountIn needed to spend to receive the desired amountOut.
//         amountIn = swapRouter.exactOutputSingle(params);

//         // For exact output swaps, the amountInMaximum may not have all been spent.
//         // If the actual amount spent (amountIn) is less than the specified maximum amount, we must refund the msg.sender and approve the swapRouter to spend 0.
//         if (amountIn < amountInMaximum) {
//             TransferHelper.safeApprove(token0, address(swapRouter), 0);
//             TransferHelper.safeTransfer(token0, msg.sender, amountInMaximum - amountIn);
//         }
//     }
// }

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
// Solidity compiler version lock kiya gaya hai

pragma abicoder v2;
// ABI Encoder V2 enable kiya
// Isse complex structs (MintParams, SwapParams etc.) safely
// function arguments aur return values me use ho sakte hain
// Uniswap V3 ke bina yeh kaam hi nahi karega

import "lib/swap-router-contracts/contracts/interfaces/IV3SwapRouter.sol";
// Uniswap V3 Swap Router ka interface
// Yahin se actual swap hota hai (exactInputSingle, exactOutputSingle)
// Trader ke swap requests isi router ke through pool tak jaate hain

import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
// ERC20 tokens ko safely transfer / approve karne ke liye helper
// Kyunki har ERC20 token standard follow nahi karta
// safeTransfer, safeApprove use karke reverts avoid hote hain

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
// Uniswap V3 Factory interface
// Factory ka kaam:
// 1) Check karna ki pool exist karta hai ya nahi
// 2) Naya pool create karna (ETH/USDC, fee tier ke hisaab se)

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
// Actual Uniswap V3 Pool ka interface
// Yahin se:
// - price (sqrtPriceX96)
// - current tick
// - liquidity
// - oracle data (slot0)
// read kiya jaata hai
// Yehi real market state hoti hai

import "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
// LP positions ko manage karne wala main contract
// Yahin se:
// - LP NFT mint hota hai
// - liquidity increase / decrease hoti hai
// - fees collect hoti hain
// Har LP position ek ERC-721 NFT hoti hai

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
// ERC-721 (NFT) receive karne ke liye mandatory interface
// Uniswap V3 LP position NFT hoti hai
// Agar yeh implement nahi kiya:
// LP mint ke time transaction revert ho jaayega

contract SimpleSwap is IERC721Receiver {
    // Yeh contract ERC721Receiver implement karta hai
    // Kyunki Uniswap V3 me LP position ek NFT (ERC-721) hoti hai
    // Agar yeh implement nahi kiya → LP mint ke time revert ho jaayega

    event PoolCreated(
        address indexed tokenA,
        address indexed tokenB,
        uint24 indexed fee,
        address pool
    );
    // Jab naya Uniswap V3 pool create hota hai
    // tokenA, tokenB, fee indexed hain → frontend / logs me easy filtering
    // Example: ETH / USDC, fee = 3000 (0.3%)

    event PoolInitialized(address indexed pool, uint160 sqrtPriceX96);
    // Jab pool ka initial price set hota hai
    // sqrtPriceX96 = √price × 2^96
    // Example: ETH = $2000 ke hisaab se initial price
    
// Jab pool ka initial price set hota hai (sirf ek baar)
// Yeh event batata hai: "Is pool ki starting price kya thi"
// sqrtPriceX96 = √price × 2^96
// IMPORTANT: Uniswap V3 direct price (2000 USDC) store nahi karta
// Protocol ke andar sirf sqrtPriceX96 store hota hai
// Ab REAL VALUES ke saath samjho 👇
// Maan lo real market me:
// 1 ETH = 2000 USDC
// price = 2000
// Step 1: Square root nikaalo
// √2000 ≈ 44.72135955
// Step 2: 2^96 se multiply karo
// 2^96 ≈ 79,228,162,514,264,337,593,543,950,336
// Step 3: Final sqrtPriceX96
// sqrtPriceX96 ≈ 44.72135955 × 2^96
// ≈ 3543191142285914378072636784640
// Yeh value integer hoti hai (uint160)
// Decimal values Solidity me allowed nahi hoti
// Isliye 2^96 se scale karke precision rakhi jaati hai
// FEEL POINT 🔥
// sqrtPriceX96 = pool ka "price meter"
// Jaise car ka speedometer
// UI me tum $2000 dekhte ho🧠 ONE-LINE FEEL (LOCK THIS)
// UI me jo $2000 dikhta hai
// contract ke andar wahi value sqrtPriceX96 ke form me chal rahi hoti hai
// Contract ke andar yeh badi integer value chal rahi hoti hai
// Jab pool initialize hota hai:
// IUniswapV3Pool(pool).initialize(sqrtPriceX96)
// Us moment pe yeh event emit hota hai
// Frontend / logs confirm karte hain ki pool ka price set ho gaya
// Example real scenario:
// ETH/USDC pool naya bana
// initialize(3543191142285914378072636784640)
// Event emit hua:
// PoolInitialized(poolAddress, 3543191142285914378072636784640)
// 
     

    IV3SwapRouter public immutable swapRouter =
        IV3SwapRouter(0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E);
    // Uniswap V3 Swap Router ka fixed address
    // Saare swaps (exactInput / exactOutput) isi router ke through jaate hain
    // immutable = deploy ke baad change nahi ho sakta (security + gas save)

    uint24 public constant feeTier = 3000;
    // Fee tier = 3000 → 0.3%
    // ETH / USDC jaise volatile pairs ke liye standard fee
    // constant = storage use nahi hota, gas efficient

    address public immutable token0;
    address public immutable token1;
    // token0 aur token1 = pool ke tokens
    // Example: token0 = WETH, token1 = USDC
    // immutable = constructor me set hoga, baad me change nahi

    IUniswapV3Factory public immutable iUniswapV3Factory =
        IUniswapV3Factory(0x0227628f3F023bb0B980b67D528571c95c6DaC1c);
    // Uniswap V3 Factory ka address
    // Factory ka kaam:
    // 1) Check karna ki pool already exist karta hai ya nahi
    // 2) Naya pool create karna (token pair + fee ke basis pe)

    INonfungiblePositionManager public immutable nonfungiblePositionManager =
        INonfungiblePositionManager(0x1238536071E1c677A632429e3655c799b22cDA52);
    // Position Manager = LP ka main control panel
    // Yahin se:
    // - LP NFT mint hota hai
    // - liquidity increase / decrease hoti hai
    // - fees collect hoti hain
    // Har LP position ek ERC-721 NFT hoti hai

    struct Deposit {
        address owner;
        // LP NFT ka owner kaun hai (EOA ya contract)

        uint128 liquidity;
        // Is LP position ki total liquidity
        // Yeh number price range ke andar active liquidity batata hai

        address token0;
        address token1;
    }
    // Is LP position ke tokens
    // Usually same as contract ke token0 / token1

    mapping(uint256 => Deposit) public deposits;
    // tokenId (LP NFT id) → Deposit struct
    // Example:
    // tokenId = 7
    // owner = Alice
    // liquidity = 123456
    // token0 = WETH
    // token1 = USDC

    constructor(address _token0, address _token1) {
        // Contract deploy karte waqt token pair set hota hai
        // Example: _token0 = WETH, _token1 = USDC

        require(_token0 != address(0) && _token1 != address(0));
        // Safety check: zero address allowed nahi
        // Zero address ka matlab token exist hi nahi karta

        token0 = _token0;
        token1 = _token1;
        // Immutable variables set ho gaye
        // Ab yeh contract sirf isi token pair ke liye kaam karega
    }

    //#3
    function createAndInitializePoolIfNecessary(
        address tokenA,
        address tokenB,
        uint24 fee,
        uint160 sqrtPriceX96
    ) external returns (address pool) {
        // STEP 1️⃣: Factory se pooch rahe ho
        // "ETH/USDC + 0.3% fee ka pool already exist karta hai kya?"
        // Example:
        // tokenA = WETH
        // tokenB = USDC
        // fee    = 3000 (0.3%)
        pool = iUniswapV3Factory.getPool(tokenA, tokenB, fee);

        // STEP 2️⃣: Agar pool nahi mila (address(0))
        // matlab:
        // - Pehli baar yeh pair + fee aa raha hai
        // - Market abhi exist hi nahi karta
        if (pool == address(0)) {
            // STEP 3️⃣: Factory ko bol rahe ho
            // "Bhai naya Uniswap V3 pool bana do"
            // Yahan sirf pool ka "empty shell" banta hai
            // Abhi price set nahi hui hai
            pool = iUniswapV3Factory.createPool(tokenA, tokenB, fee);

            // STEP 4️⃣: Event emit
            // Frontend / logs ko pata chale:
            // "ETH/USDC 0.3% pool ban gaya"
            emit PoolCreated(tokenA, tokenB, fee, pool);
        }

        // STEP 5️⃣: Ab pool ke andar jaake dekhte ho
        // "Is pool ka price set hai ya nahi?"
        // slot0 = pool ka brain
        // Isme:
        // - sqrtPriceX96
        // - current tick
        // - oracle data
        // sab hota hai
        (uint160 currentSqrtPriceX96, , , , , , ) = IUniswapV3Pool(pool)
            .slot0();

        // STEP 6️⃣: Agar sqrtPriceX96 = 0
        // Matlab:
        // - Pool freshly bana hai
        // - Abhi tak koi price set nahi hui
        // - Trading start hi nahi ho sakti
        if (currentSqrtPriceX96 == 0) {
            // STEP 7️⃣: Pool ko initialize kar rahe ho
            // sqrtPriceX96 = √price × 2^96
            //
            // REAL VALUE EXAMPLE 👇
            // Maan lo real market me:
            // 1 ETH = 2000 USDC
            //
            // √2000 ≈ 44.7213
            // 2^96 ≈ 7.9e28
            //
            // sqrtPriceX96 ≈ 44.7213 × 2^96
            // ≈ 3543191142285914378072636784640
            //
            // Yeh value pool ka "starting price meter" ban jaati hai
            IUniswapV3Pool(pool).initialize(sqrtPriceX96);

            // STEP 8️⃣: Event emit
            // Logs ko pata chale:
            // "Pool initialize ho gaya, price set ho gaya"
            emit PoolInitialized(pool, sqrtPriceX96);
        }

        // STEP 9️⃣: Finally pool address return
        // Ab:
        // - Pool exist karta hai
        // - Price set hai
        // - Liquidity add ki ja sakti hai
        // - Trading start ho sakti hai
        return pool;
    }

    function getSqrtPriceX96For1to10Ratio() public pure returns (uint160) {
        return 250541448375047931186413801569;
    }

    function getCurrentTick() external view returns (int24) {
        address pool = iUniswapV3Factory.getPool(token0, token1, feeTier);
        (, int24 tick, , , , , ) = IUniswapV3Pool(pool).slot0();
        return tick;
    }

    function getTickRangeAroundCurrent(
        int24 tickDistance
    ) external view returns (int24 lowerTick, int24 upperTick) {
        int24 currentTick = this.getCurrentTick();
        int24 tickSpacing = 60;

        lowerTick = ((currentTick - tickDistance) / tickSpacing) * tickSpacing;
        upperTick = ((currentTick + tickDistance) / tickSpacing) * tickSpacing;
    }

    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address) {
        return iUniswapV3Factory.getPool(tokenA, tokenB, fee);
    }

    //#1
    function onERC721Received(
        address operator,
        address,
        uint256 tokenId,
        bytes calldata
    ) external override returns (bytes4) {
        // Yeh function tab call hota hai jab koi ERC-721 NFT
        // is contract ko bheja jaata hai
        // Uniswap V3 me LP position = ERC-721 NFT
        // REAL SCENARIO 👇
        // Tumne mintNewPosition() call kiya
        // NonfungiblePositionManager ne LP NFT mint ki
        // NFT ko recipient = address(this) bheja
        // Jaise hi NFT aata hai → yeh function auto-trigger hota hai
        // operator = jisne mintNewPosition call kiya
        // Example: operator = tumhara wallet (Dhruv)
        // tokenId = LP NFT ka unique ID
        // Example: tokenId = 42
        _createDeposit(operator, tokenId);
        // Ab hum LP NFT ke andar ka DATA read kar rahe hain
        // Aur apne contract ke storage me save kar rahe hain
        // Taki baad me:
        // - liquidity track kar sake
        // - owner verify kar sake
        return this.onERC721Received.selector;
        // Yeh return mandatory hai
        // Iska matlab:
        // "Haan bhai, NFT safely receive kar liya"
        // Agar yeh return nahi hua → transaction revert
    }
    // 🔥 AB SECOND FUNCTION — REAL MAGIC YAHAN HAI
    //#2
    function _createDeposit(address owner, uint256 tokenId) internal {
        // owner = jo LP bana (operator se aaya)
        // Example: owner = Dhruv
        // tokenId = LP NFT ID (Example: 42)
        (
            ,
            ,
            address posToken0,
            address posToken1,
            ,
            ,
            ,
            uint128 liquidity,
            ,
            ,
            ,

        ) = nonfungiblePositionManager.positions(tokenId);
        // positions(tokenId) ek HUGE struct return karta hai
        // Usme bohot saari cheeze hoti hain
        // Hum sirf jo hume chahiye wahi nikaal rahe hain
        // REAL DATA jo positions() ke andar hota hai 👇
        // token0 = WETH
        // token1 = USDC
        // tickLower = 198600  (~$1800)
        // tickUpper = 199800  (~$2200)
        // liquidity = 1234567890123  (example)
        // Commas ( , ) ka matlab:
        // "Is value ko ignore karo"
        // Kyunki:
        // - hume feeGrowth
        // - hume owed tokens
        // - hume ticks yahan nahi chahiye
        // posToken0 = WETH address
        // posToken1 = USDC address
        // liquidity = actual active liquidity of this LP position
        deposits[tokenId] = Deposit(owner, liquidity, posToken0, posToken1);
        // Ab hum apne contract ke storage me save kar rahe hain
        // mapping[42] = {
        //   owner: Dhruv,
        //   liquidity: 1234567890123,
        //   token0: WETH,
        //   token1: USDC
        // }
        // FEEL POINT 🔥
        // Yeh moment pe:
        // NFT sirf ek jpeg nahi hai
        // Yeh ek "live trading strategy" ban chuki hai
        // Jiska data tumhare contract ko pata hai

        // agar nft me yeh sab likha hua hota hai tokens,ticklower/upper and all and contract can read this ?

        // Short answer: HAAN ✅
        // Aur ab main exact feel ke saath batata hoon kaise.

        // 🔑 DIRECT ANSWER (LOCK THIS FIRST)

        // LP NFT ke andar yeh sab data likha hota hai
        // (token0, token1, tickLower, tickUpper, liquidity, fees, etc.)
        // Aur koi bhi contract isko READ kar sakta hai
        // using NonfungiblePositionManager.positions(tokenId).

        // NFT = sirf image ❌
        // NFT = on-chain structured data + ownership ✅

        // 🧠 AB FEEL KE SAATH SAMJHO (STEP BY STEP)
        // 1️⃣ LP NFT KYA HAI ACTUALLY?

        // Uniswap V3 me LP position:

        // ERC-721 NFT hai

        // Metadata image nahi

        // Stateful on-chain record

        // Socho jaise:

        // NFT = ek on-chain database row

        // 2️⃣ NFT KE ANDAR EXACTLY KYA STORED HAI?

        // Jab tum LP NFT mint karte ho,
        // NonfungiblePositionManager internally yeh data store karta hai:

        // positions[tokenId] = {
        //   operator,
        //   token0,
        //   token1,
        //   fee,
        //   tickLower,
        //   tickUpper,
        //   liquidity,
        //   feeGrowthInside0LastX128,
        //   feeGrowthInside1LastX128,
        //   tokensOwed0,
        //   tokensOwed1
        // }

        // 👉 Yeh struct hai, image nahi.

        // 3️⃣ TUMHARA CONTRACT ISKO KAISE READ KAR RAHA HAI?

        // Tumhara code 👇

        // (,, address posToken0, address posToken1,,,, uint128 liquidity,,,,)
        //     = nonfungiblePositionManager.positions(tokenId);

        // 🧠 FEEL:

        // Tum NFT ka locker khol rahe ho

        // Sirf jo chahiye wahi nikaal rahe ho

        // Baaki cheeze ignore kar rahe ho

        // 4️⃣ REAL VALUES KE SAATH FEEL

        // Maan lo:

        // ETH/USDC LP NFT

        // tokenId = 42

        // Contract ke andar yeh pada hota hai:

        // token0     = WETH
        // token1     = USDC
        // tickLower  = 198600   (~$1800)
        // tickUpper  = 199800   (~$2200)
        // liquidity  = 1,234,567,890

        // Tumhara contract jab call karta hai:

        // nonfungiblePositionManager.positions(42)

        // 👉 Exact yahi values milti hain

        // 5️⃣ KYA YEH DATA CHANGE HOTA HAI?

        // ✔️ YES (partially)

        // Field	Change hota hai?
        // token0 / token1	❌ Never
        // tickLower / tickUpper	❌ Never
        // liquidity	✅ Increase / Decrease
        // tokensOwed	✅ Fees aati rehti hain

        // 🧠 FEEL:

        // NFT = fixed strategy + live balances

        // 6️⃣ KYA KOI BHI CONTRACT ISKO READ KAR SAKTA HAI?

        // YES 100% ✅

        // Kyuki:

        // positions(tokenId) = public view

        // Blockchain = transparent

        // So:

        // Tumhara contract

        // Kisi aur ka contract

        // Frontend

        // Analytics tools

        // Sab is LP NFT ko inspect kar sakte hain.

        // 7️⃣ PHIR OWNER KA ROLE KYA HAI?

        // Owner ka role:

        // Liquidity change kar sakta hai

        // Fees collect kar sakta hai

        // NFT transfer kar sakta hai

        // ❌ Owner data chhupa nahi sakta
        // ❌ Owner tick range change nahi kar sakta
    }

    //#4
    function mintNewPosition(
        int24 lowerTick,
        int24 upperTick
    )
        external
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        )
    {
        // STEP 1️⃣: Factory se pool nikaalte ho
        // Example:
        // token0 = WETH
        // token1 = USDC
        // feeTier = 3000 (0.3%)
        // Agar pool exist karta hai to yahin mil jaata hai
        address pool = iUniswapV3Factory.getPool(token0, token1, feeTier);

        // STEP 2️⃣: Pool ka current price nikaalte ho
        // slot0 ke andar sqrtPriceX96 hota hai
        // sqrtPriceX96 = √(USDC / ETH) × 2^96
        // Example:
        // ETH ≈ $2000
        // sqrtPriceX96 ≈ 3543191142285914378072636784640
        (uint160 sqrtPriceX96, , , , , , ) = IUniswapV3Pool(pool).slot0();

        // STEP 3️⃣: Safety check
        // Agar sqrtPriceX96 = 0 hai
        // matlab pool initialize nahi hua
        // liquidity add karna allowed nahi
        require(sqrtPriceX96 > 0);

        // STEP 4️⃣: Tum kitna capital dena chahte ho (max limit)
        // Example:
        // amount0ToMint = 100 ETH
        // amount1ToMint = 1000 USDC
        // (Note: actual used amount range + price pe depend karega)
        uint256 amount0ToMint = 100 ether;
        uint256 amount1ToMint = 1000 ether;

        // STEP 5️⃣: PositionManager ko permission dete ho
        // "Agar zarurat ho to mere tokens le lena"

        //         PEHLE ONE-LINE FEEL (LOCK THIS)

        // safeApprove ka matlab hai:
        // “Main apna purse khol ke rakh raha hoon,
        // lekin paise tabhi nikalna jab kaam sach-me ho.”

        // 🧠 STEP 0: CONFUSION KYUN HOTI HAI?

        // Tum soch rahe ho:

        // “Main to mint kar raha hoon,
        // approve kyun karna pad raha hai?”

        // Answer:

        // Kyunki tum khud mint nahi kar rahe,
        // NonfungiblePositionManager tumhari taraf se mint kar raha hai.

        // 🧑‍💻 REAL SCENE (NO CODE FIRST)
        // Tumhare paas:

        // 100 ETH

        // 1000 USDC

        // Tum chahte ho:

        // “Uniswap jaake liquidity add karni hai”

        // Par problem:

        // Tokens tumhare wallet me hain

        // Mint dusra contract karega

        // ⚠️ Tumne paise abhi diye nahi
        // Bas permission di

        // Yahi approve hai.

        // 🔁 AB CODE LINE KO FEEL KE SAATH DEKHO
        // TransferHelper.safeApprove(
        //     token0,
        //     address(nonfungiblePositionManager),
        //     amount0ToMint
        // );
        // ✔️ Kaunsi token? → token0
        // ✔️ Kaun le sakta hai? → nonfungiblePositionManager
        // ✔️ Kitna max? → amount0ToMint
        // Example:

        // amount0ToMint = 100 ETH

        // Matlab:

        // “PositionManager max 100 ETH le sakta hai
        // (kam bhi le sakta hai, zyada nahi)”

        // TransferHelper.safeApprove(
        //     token1,
        //     address(nonfungiblePositionManager),
        //     amount1ToMint
        // );

        // Example:

        // amount1ToMint = 1000 USDC

        // Matlab:

        // “PositionManager max 1000 USDC le sakta hai”

        // 🔥 IMPORTANT FEEL MOMENT (PLEASE READ)

        // Approve ≠ Transfer

        // ❌ Approve karne se token move nahi hota
        // ❌ Balance kam nahi hota

        // ✔️ Sirf permission set hoti hai

        // 🧠 STEP-BY-STEP REAL FLOW (THIS IS THE CLICK)
        // 1️⃣ Approve
        // ETH = 100
        // USDC = 1000

        // Wallet unchanged ✅

        // 2️⃣ mint() call hoti hai

        // PositionManager:

        // Pool ka price dekhta hai

        // Tick range dekhta hai

        // Example decision:

        // Sirf 2.4 ETH aur 5200 USDC chahiye

        // 3️⃣ Actual transfer hota hai

        // PositionManager internally karta hai:

        // transferFrom(user, pool, 2.4 ETH)
        // transferFrom(user, pool, 5200 USDC)

        // Wallet:

        // ETH = 97.6
        // USDC = 4800

        // 4️⃣ Extra allowance bachi reh jaati hai

        // Approve tha:

        // 100 ETH

        // Use hua:

        // 2.4 ETH

        // Remaining:

        // 97.6 ETH allowance (unused)

        // (Usually baad me reset kar dete hain)

        // 🔐 KYUN safeApprove?

        // Normal approve me:

        // Kuch tokens (USDT) buggy hote hain

        // Race condition ho sakti hai

        // TransferHelper.safeApprove:

        // Token return value check karta hai

        // Revert karta hai agar fail ho

        // Safer wrapper hai

        // TransferHelper.safeTransferFrom(
        //     token0,
        //     msg.sender,
        //     address(this),
        //     amount0ToMint
        // );
        // TransferHelper.safeTransferFrom(
        //     token1,
        //     msg.sender,
        //     address(this),
        //     amount1ToMint
        // );

        TransferHelper.safeApprove(
            token0,
            address(nonfungiblePositionManager),
            amount0ToMint
        );
        TransferHelper.safeApprove(
            token1,
            address(nonfungiblePositionManager),
            amount1ToMint
        );

        // STEP 6️⃣: LP strategy define kar rahe ho
        // Yeh poora struct ek LP ki "rule-book" hai
        // Example feel:
        // "Main ETH $1800 se $2200 ke beech market maker banna chahta hoon"
        INonfungiblePositionManager.MintParams
            memory params = INonfungiblePositionManager.MintParams({
                token0: token0, // WETH
                token1: token1, // USDC
                fee: feeTier, // 0.3%
                tickLower: lowerTick, // ~ $1800
                tickUpper: upperTick, // ~ $2200
                amount0Desired: amount0ToMint, // max ETH ready
                amount1Desired: amount1ToMint, // max USDC ready
                //👉 “Main itna MAX dene ke liye ready hoon”
                //Tum bolte ho:
                // “Main max 100 ETH de sakta hoon”
                // “Main max 1000 USDC de sakta hoon”
                amount0Min: 0, // slippage ignore (demo)
                amount1Min: 0,
                /*
                amount0Min / amount1Min
                👉 “Isse kam hua to deal cancel”
                Agar:actual used < amountMin
                    → transaction revert ❌
                    → LP NFT mint hi nahi hota
                 */
                recipient: address(this), // NFT yahin milega
                deadline: block.timestamp
            });

        // STEP 7️⃣: Actual mint call
        // Yahin pe magic hota hai:
        // - Protocol decide karta hai:
        //   current price + range ke hisaab se
        //   kitna ETH aur kitna USDC actually use hoga
        // - Baaki refund ho jaata hai
        (tokenId, liquidity, amount0, amount1) = nonfungiblePositionManager
            .mint(params);

        // Example real feel:
        // Current ETH ≈ $2000 (range ke beech)
        // amount0 ≈ 2.4 ETH
        // amount1 ≈ 5200 USDC
        // liquidity ≈ L (internal abstract number)

        // STEP 8️⃣: NFT ko apne internal accounting me save kar rahe ho
        // tokenId = LP NFT id
        // deposits[tokenId] me:
        // - owner
        // - liquidity
        // - token0/token1
        _createDeposit(msg.sender, tokenId);

        if (amount0 < amount0ToMint) {
            TransferHelper.safeApprove(
                token0,
                address(nonfungiblePositionManager),
                0
            );
            uint256 refund0 = amount0ToMint - amount0;
            TransferHelper.safeTransfer(token0, msg.sender, refund0);
        }

        if (amount1 < amount1ToMint) {
            TransferHelper.safeApprove(
                token1,
                address(nonfungiblePositionManager),
                0
            );
            uint256 refund1 = amount1ToMint - amount1;
            TransferHelper.safeTransfer(token1, msg.sender, refund1);
        }
    }

    //#5
    function increaseLiquidityCurrentRange(
        // =======================
        // 🧠 SCENE SETUP (REAL VALUES)
        // =======================

        // Pool: ETH / USDC (0.3%)
        // Tum already LP ho
        // Tumhare paas ek LP NFT hai

        // tokenId = 101
        // tick range = $1800 – $2200
        // current ETH price = $2000 (range ke andar ✅)

        // Tum sochte ho:
        // “Is range me volume zyada aa raha hai,
        //  main aur capital add karta hoon.”
        uint256 tokenId, // Example: 101 (existing LP NFT)
        uint256 amountAdd0, // Example: 1 ETH
        uint256 amountAdd1 // Example: 2000 USDC
    ) external returns (uint128 liquidity, uint256 amount0, uint256 amount1) {
        // =======================
        // 🔹 STEP 1️⃣ — APPROVE (PERMISSION)
        // =======================

        // Tum token0 (ETH) ke liye permission de rahe ho
        // "PositionManager tum mere wallet se
        //  max 1 ETH le sakta hai"
        TransferHelper.safeApprove(
            token0,
            address(nonfungiblePositionManager),
            amountAdd0
        );

        //         🔑 SHORT ANSWER (LOCK THIS)

        // YES, assets pehle tumhare wallet se SimpleSwap contract me aate hain,
        // phir SimpleSwap contract NonfungiblePositionManager ko approve karta hai,
        // aur phir PositionManager wahi assets SimpleSwap se le leta hai.

        // 👉 LP ke time assets DIRECT user → PositionManager nahi jaate
        // 👉 Assets user → tumhara contract → PositionManager jaate hain

        // Tumhara understanding correct hai ✅

        // Tum token1 (USDC) ke liye permission de rahe ho
        // "PositionManager tum mere wallet se
        //  max 2000 USDC le sakta hai"
        TransferHelper.safeApprove(
            token1,
            address(nonfungiblePositionManager),
            amountAdd1
        );

        // ❗ Is point pe:
        // ❌ Koi ETH nahi gaya
        // ❌ Koi USDC nahi gaya
        // ✔️ Sirf permission set hui

        // =======================
        // 🔹 STEP 2️⃣ — RULES SET KARNA (PARAMS)
        // =======================

        // Tum bol rahe ho:
        // "Issi LP NFT (tokenId = 101)
        //  ke SAME price range me
        //  aur liquidity add karo"

        // Important FEEL:
        // ❌ tickLower change nahi hota
        // ❌ tickUpper change nahi hota
        // ✔️ Strategy same rehti hai
        // ✔️ Sirf position ka size badhta hai

        INonfungiblePositionManager.IncreaseLiquidityParams
            memory params = INonfungiblePositionManager
                .IncreaseLiquidityParams({
                    tokenId: tokenId, // Kaunsi LP position? → 101
                    amount0Desired: amountAdd0, // Max ETH ready → 1 ETH
                    amount1Desired: amountAdd1, // Max USDC ready → 2000 USDC
                    amount0Min: 0, // Demo mode: "Jo mile, chalega"
                    amount1Min: 0, // (Production me risky)
                    deadline: block.timestamp
                });

        // =======================
        // 🔹 STEP 3️⃣ — ACTUAL EXECUTION
        // =======================

        // Yahin real action hota hai
        // Protocol internally:
        // 1. Current price dekhta hai → $2000
        // 2. Tumhari range dekhta hai → $1800–$2200
        // 3. Decide karta hai:
        //    kitna ETH + USDC actually chahiye

        (liquidity, amount0, amount1) = nonfungiblePositionManager
            .increaseLiquidity(params);

        // Example REAL RESULT:
        // amount0 = 0.95 ETH
        // amount1 = 1900 USDC
        // liquidity = +350000

        // Matlab:
        // Tumne bola tha "max 1 ETH, 2000 USDC"
        // Protocol ne bola "mujhe sirf itna chahiye"

        // =======================
        // 🔹 STEP 4️⃣ — INTERNAL ACCOUNTING
        // =======================

        // Tum apne contract me LP ki liquidity update kar rahe ho
        deposits[tokenId].liquidity += liquidity;

        // Example FEEL:
        // Pehle liquidity = 1,000,000
        // Ab liquidity = 1,350,000

        // 👉 Same price range
        // 👉 Same strategy
        // 👉 Zyada fees earn karoge
    }

    //#6
    function decreaseLiquidityInHalf(
        uint256 tokenId
    ) external returns (uint256 amount0, uint256 amount1) {
        // ===============================
        // 🧠 SCENE SETUP (REAL FEEL)
        // ===============================
        // Pool: ETH / USDC (0.3%)
        // tokenId = 101 (LP NFT)
        // tick range = $1800 – $2200
        // current ETH price = $2000 (range ke andar)
        //
        // Maan lo LP ki total liquidity:
        // deposits[101].liquidity = 1,350,000
        //
        // Tum sochte ho:
        // "Main thoda profit nikaal leta hoon,
        //  poora LP band nahi karna"

        // ===============================
        // 🔹 STEP 1️⃣ — CURRENT LIQUIDITY PADHNA
        // ===============================
        uint128 liquidity = deposits[tokenId].liquidity;

        // Example:
        // liquidity = 1,350,000

        // ===============================
        // 🔹 STEP 2️⃣ — HALF LIQUIDITY CALCULATE
        // ===============================
        uint128 half = liquidity / 2;

        // Example:
        // half = 675,000
        //
        // FEEL:
        // "Main apni LP position ka 50% withdraw karunga"

        // ===============================
        // 🔹 STEP 3️⃣ — DECREASE PARAMS BANANA
        // ===============================
        // Tum PositionManager ko bol rahe ho:
        // "Is LP NFT se itni liquidity jala do"

        INonfungiblePositionManager.DecreaseLiquidityParams
            memory params = INonfungiblePositionManager
                .DecreaseLiquidityParams({
                    tokenId: tokenId, // Kaunsi LP? → 101
                    liquidity: half, // Kitni liquidity nikaalni hai → 50%
                    amount0Min: 0, // Demo: slippage ignore
                    amount1Min: 0,
                    deadline: block.timestamp
                });

        // IMPORTANT FEEL:
        // ❌ NFT destroy nahi ho rahi
        // ❌ Position close nahi ho rahi
        // ✔️ Sirf liquidity kam ho rahi hai

        // ===============================
        // 🔹 STEP 4️⃣ — ACTUAL LIQUIDITY BURN
        // ===============================
        // Yahin pe pool se assets unlock hote hain
        nonfungiblePositionManager.decreaseLiquidity(params);

        // Internally kya hota hai:
        // - Pool math dekhta hai
        // - Current price dekhta hai ($2000)
        // - Decide karta hai:
        //   kitna ETH + USDC wapas dena hai

        // ===============================
        // 🔹 STEP 5️⃣ — COLLECT (ASSETS + FEES)
        // ===============================
        // decreaseLiquidity ke baad:
        // ETH + USDC PositionManager ke paas hote hain
        // Ab tum unko collect karte ho

        (amount0, amount1) = nonfungiblePositionManager.collect(
            INonfungiblePositionManager.CollectParams({
                tokenId: tokenId,
                recipient: address(this), // Pehle contract me aayenge
                amount0Max: type(uint128).max, // Jitna bhi ETH ho
                amount1Max: type(uint128).max // Jitni bhi USDC ho
            })
        );

        // Example REAL RESULT:
        // amount0 = 0.48 ETH
        // amount1 = 960 USDC
        //
        // FEEL:
        // "Maine apni LP ka aadha paisa nikaal liya"

        // ===============================
        // 🔹 STEP 6️⃣ — OWNER KO PAISA BHEJNA
        // ===============================
        // Contract sirf middleman hai
        // Final paisa LP owner ko bhejna hai

        _sendToOwner(tokenId, amount0, amount1);

        // _sendToOwner ke andar:
        // TransferHelper.safeTransfer(token0, owner, amount0);
        // TransferHelper.safeTransfer(token1, owner, amount1);

        // ===============================
        // 🧠 FINAL FEEL SUMMARY
        // ===============================
        // ✔️ LP NFT same rahi
        // ✔️ Price range same rahi
        // ✔️ Strategy same rahi
        // ✔️ Liquidity 50% kam ho gayi
        // ✔️ Assets + fees wallet me aa gaye
    }

    function _sendToOwner(
        uint256 tokenId,
        uint256 amount0,
        uint256 amount1
    ) internal {
        address owner = deposits[tokenId].owner;
        TransferHelper.safeTransfer(deposits[tokenId].token0, owner, amount0);
        TransferHelper.safeTransfer(deposits[tokenId].token1, owner, amount1);
    }

    //#7
    function swapExactInputSingle(
        uint256 amountIn // Example: 1 ETH
    ) external returns (uint256 amountOut) {
        // ===============================
        // 🧠 SCENE SETUP (REAL FEEL)
        // ===============================
        // Pool: ETH / USDC (0.3%)
        // Current price: 1 ETH ≈ 2000 USDC
        //
        // User bolta hai:
        // "Main EXACT 1 ETH dunga,
        //  jitni USDC mile, de do"

        // ===============================
        // 🔹 STEP 1️⃣ — USER → CONTRACT TRANSFER
        // ===============================
        // User apna ETH tumhare contract ko deta hai
        // User ne pehle is contract ko approve kiya hona chahiye
        TransferHelper.safeTransferFrom(
            token0, // token0 = ETH (or WETH)
            msg.sender, // User
            address(this), // Tumhara contract
            amountIn // 1 ETH
        );

        // Ab:
        // Contract ke paas 1 ETH aa gaya

        // ===============================
        // 🔹 STEP 2️⃣ — CONTRACT → ROUTER APPROVE
        // ===============================
        // Tum swapRouter ko permission de rahe ho:
        // "Tum mere contract se max 1 ETH le sakte ho"
        TransferHelper.safeApprove(token0, address(swapRouter), amountIn);

        // ===============================
        // 🔹 STEP 3️⃣ — SWAP RULES DEFINE KARNA
        // ===============================
        IV3SwapRouter.ExactInputSingleParams memory params = IV3SwapRouter
            .ExactInputSingleParams({
                tokenIn: token0, // ETH
                tokenOut: token1, // USDC
                fee: feeTier, // 0.3%
                recipient: msg.sender, // Final USDC user ko milegi
                amountIn: amountIn, // EXACT 1 ETH
                amountOutMinimum: 0, // ❌ RISKY (slippage protection nahi)
                sqrtPriceLimitX96: 0 // No price limit
            });

        // amountOutMinimum = 0 ka matlab:
        // "Chahe kitni bhi kam USDC mile, deal cancel mat karna"
        // ⚠️ Production me yeh DANGEROUS hai

        // ===============================
        // 🔹 STEP 4️⃣ — ACTUAL SWAP
        // ===============================
        amountOut = swapRouter.exactInputSingle(params);

        // Example RESULT:
        // amountOut ≈ 1985 USDC (fee + price impact ke baad)

        // ===============================
        // 🧠 FINAL FEEL
        // ===============================
        // User ne EXACT 1 ETH diya
        // User ko variable USDC mili
    }
    //#8
    function swapExactInputSingle(
        uint256 amountIn // Example: 1 ETH
    ) external returns (uint256 amountOut) {
        // ===============================
        // 🧠 SCENE SETUP (REAL FEEL)
        // ===============================
        // Pool: ETH / USDC (0.3%)
        // Current price: 1 ETH ≈ 2000 USDC
        //
        // User bolta hai:
        // "Main EXACT 1 ETH dunga,
        //  jitni USDC mile, de do"

        // ===============================
        // 🔹 STEP 1️⃣ — USER → CONTRACT TRANSFER
        // ===============================
        // User apna ETH tumhare contract ko deta hai
        // User ne pehle is contract ko approve kiya hona chahiye
        TransferHelper.safeTransferFrom(
            token0, // token0 = ETH (or WETH)
            msg.sender, // User
            address(this), // Tumhara contract
            amountIn // 1 ETH
        );

        // Ab:
        // Contract ke paas 1 ETH aa gaya

        // ===============================
        // 🔹 STEP 2️⃣ — CONTRACT → ROUTER APPROVE
        // ===============================
        // Tum swapRouter ko permission de rahe ho:
        // "Tum mere contract se max 1 ETH le sakte ho"
        TransferHelper.safeApprove(token0, address(swapRouter), amountIn);

        // ===============================
        // 🔹 STEP 3️⃣ — SWAP RULES DEFINE KARNA
        // ===============================
        IV3SwapRouter.ExactInputSingleParams memory params = IV3SwapRouter
            .ExactInputSingleParams({
                tokenIn: token0, // ETH
                tokenOut: token1, // USDC
                fee: feeTier, // 0.3%
                recipient: msg.sender, // Final USDC user ko milegi
                amountIn: amountIn, // EXACT 1 ETH
                amountOutMinimum: 0, // ❌ RISKY (slippage protection nahi)
                sqrtPriceLimitX96: 0 // No price limit
            });

        // amountOutMinimum = 0 ka matlab:
        // "Chahe kitni bhi kam USDC mile, deal cancel mat karna"
        // ⚠️ Production me yeh DANGEROUS hai

        // ===============================
        // 🔹 STEP 4️⃣ — ACTUAL SWAP
        // ===============================
        amountOut = swapRouter.exactInputSingle(params);

        // Example RESULT:
        // amountOut ≈ 1985 USDC (fee + price impact ke baad)

        // ===============================
        // 🧠 FINAL FEEL
        // ===============================
        // User ne EXACT 1 ETH diya
        // User ko variable USDC mili
    }

    //#6
    function collectAllFees(
        uint256 tokenId
    ) external returns (uint256 amount0, uint256 amount1) {
        // ===============================
        // 🧠 STEP 0: BASIC REQUIREMENT
        // ===============================
        // Is LP NFT (tokenId) ka owner caller hona chahiye
        // Kyunki fees sirf owner hi collect kar sakta hai
        // (yeh check usually bahar require se hota hai)

        // ===============================
        // 🔹 STEP 1: NFT KO TEMPORARILY CONTRACT ME LAANA
        // ===============================
        // safeTransferFrom:
        // NFT (LP position) owner → yeh contract
        //
        // Kyun?
        // Kyunki collect() call karne ke liye
        // PositionManager ko NFT owner chahiye hota hai
        //
        // Flow:
        // msg.sender (LP owner)
        //   ↓
        // address(this) (tumhara contract)
        nonfungiblePositionManager.safeTransferFrom(
            msg.sender,
            address(this),
            tokenId
        );

        // ⚠️ IMPORTANT FEEL:
        // NFT permanently nahi ja rahi
        // Sirf is function ke time ke liye contract ke paas hai

        // ===============================
        // 🔹 STEP 2: COLLECT PARAMS SET KARNA
        // ===============================
        // Ab tum PositionManager ko bol rahe ho:
        // "Is NFT se jitni bhi fees jama hui hain,
        //  sab nikaal do"

        INonfungiblePositionManager.CollectParams
            memory params = INonfungiblePositionManager.CollectParams({
                tokenId: tokenId, // Kaunsi LP NFT?
                recipient: address(this), // Fees pehle contract me aayengi
                amount0Max: type(uint128).max, // token0 ki ALL fees
                amount1Max: type(uint128).max // token1 ki ALL fees
            });

        // amount0Max / amount1Max = uint128 max
        // Matlab:
        // "Jitni bhi fees hain, sab collect kar lo"

        // ===============================
        // 🔹 STEP 3: ACTUAL FEE COLLECTION
        // ===============================
        // Yahin se fees move hoti hain
        //
        // Internally kya hota hai:
        // Pool → PositionManager → yeh contract

        (amount0, amount1) = nonfungiblePositionManager.collect(params);

        // Example REAL FEEL:
        // amount0 = 0.12 ETH
        // amount1 = 240 USDC
        //
        // Matlab:
        // LP ne trading fees kama li 🎉

        // ===============================
        // 🔹 STEP 4: FEES OWNER KO BHEJNA
        // ===============================
        // Ab contract sirf middleman hai
        // Final paisa owner ko bhejna hai

        _sendToOwner(tokenId, amount0, amount1);

        // _sendToOwner ke andar:
        // TransferHelper.safeTransfer(token0, owner, amount0);
        // TransferHelper.safeTransfer(token1, owner, amount1);

        // ===============================
        // 🔹 STEP 5: NFT WAPAS OWNER KO
        // ===============================
        // (Aksar yeh step function ke end me hota hai)
        // NFT owner → wapas msg.sender

        nonfungiblePositionManager.safeTransferFrom(
            address(this),
            msg.sender,
            tokenId
        );

        // ===============================
        // 🧠 FINAL FEEL SUMMARY
        // ===============================
        // 1️⃣ NFT contract ke paas aayi
        // 2️⃣ Fees collect hui
        // 3️⃣ Fees owner ko gayi
        // 4️⃣ NFT wapas owner ko mili
    }
}
