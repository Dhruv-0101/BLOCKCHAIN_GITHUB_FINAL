/** 
 * @title SingleAssetStableCoin (SSC)
 * @author Dhruv Patel
 * @notice 🌟 **THE DEFI ODYSSEY: THE STORY OF ALICE & BOB** 🌟
 * 
 * 📜 **THE SCENARIO FOR THIS ENTIRE CONTRACT:**
 * -----------------------------------------------
 * 🪐 **PART 1: THE BIRTH (Alice enters)**
 *   - Alice has **2 ETH** (The Gold).
 *   - ETH Price is **$2,500** (Fetched by `_getUsdValue`).
 *   - Her total Collateral value = **$5,000**.
 * 
 * 🪐 **PART 2: THE SACRIFICE (Minting debt)**
 *   - Alice borrows **$2,000 SSC** (The Debt).
 *   - Her Health Factor = (5000 * 0.5) / 2000 = **1.25** (SAFE! 🏰).
 * 
 * 🪐 **PART 3: THE STORM (The Market Crash)**
 *   - ETH Price crashes to **$1,800**.
 *   - Alice's Collateral value = 2 * 1800 = **$3,600**.
 *   - Her Health Factor = (3600 * 0.5) / 2000 = **0.9** (DANGER! 📉).
 * 
 * 🪐 **PART 4: THE RECKONING (Bob the Hunter)**
 *   - Bob sees Alice is underwater (< 1.0).
 *   - Bob pays **$1,000 SSC** to clear half her debt.
 *   - Bob gets Alice's ETH worth $1,000 + 10% bounty = **$1,100**.
 *   - Alice is left with **1.38 ETH** and **$1,000** debt. (Health = 1.2+ SAFE again!).
 */
 /*
 Stage 1: The Rules
This "Bank" has two strict rules to keep the system safe:

The Gold Standard (Collateral): You can only borrow money if you deposit $2 worth of Gold (ETH) for every $1 you borrow (SSC). (This is the 50% Liquidation Threshold).
The Penalty (Liquidation): If your Gold's value drops and fails the $2:$1 ratio, any "Hunter" can step in, pay your debt, and take your Gold at a discount.
Stage 2: Alice Enters (The Golden Days) ☀️
Alice has: 2 ETH.
ETH Price: $2,500 per ETH.
Alice's Total Wealth: $5,000 (2 ETH * $2,500).
The Loan: Alice borrows (mints) $2,000 SSC.
The Mathematical Check: The Bank says: "Alice, you have $5,000 in Gold. Since our threshold is 50%, you could have borrowed up to $2,500. Since you only took $2,000, you are Safe!" (Health Factor = (5000 * 0.5) / 2000 = 1.25) ✅

Stage 3: The Storm (Market Crash) 📉
Suddenly, the market crashes.

New ETH Price: $1,800.
Alice's Gold Value: Now worth $3,600 (2 ETH * $1,800).
What is the Danger? The Bank says: "Alice, with only $3,600 in Gold, your debt should not exceed $1,800 (50%). But you owe us $2,000!" (Health Factor = (3600 * 0.5) / 2000 = 0.9) 🚨 DANGER!

Alice’s Health Factor is below 1.0. Her account is now "Under-collateralized" and open for liquidation.

Stage 4: Bob the Hunter (The Liquidation) 🐺
Enter Bob. Bob is a "Bounty Hunter." He doesn't care about Alice; he only cares about Profit.

Bob sees the opportunity: "Alice owes $2,000, but she has $3,600 worth of ETH sitting there."

Bob's Move: Bob pays the bank $1,000 SSC (clearing half of Alice's debt).
Bob's Reward: The Bank says, "Since you cleared $1,000 of debt, you can take $1,000 worth of Alice's ETH plus a 10% Bonus ($100) for your service!"
The Result: Bob spent $1,000 and received $1,100 worth of ETH. Bob just made a $100 profit in a single transaction.
Stage 5: Recovery (The New Normal) 🕊️
Let’s look at Alice's new account status:

Remaining Debt: $2,000 - $1,000 (paid by Bob) = $1,000.
Remaining Gold: $3,600 - $1,100 (taken by Bob) = $2,500.
The New Health Factor: Alice has $2,500 in Gold. The Bank says 50% of that ($1,250) is the safe debt limit. Alice’s debt is only $1,000. (Health Factor = (2500 * 0.5) / 1000 = 1.25) ✅ SAFE AGAIN!

The Core Concept (The "Feel")
Why is Alice okay? Her account wasn't completely wiped out. She lost a $100 "fine" (the bonus to Bob), but her remaining $2,500 in ETH is now safe.
Why is Bob happy? He got a "Free Lunch." He turned $1,000 into $1,100 effortlessly.
Why is the System happy? Alice’s "Bad Debt" was removed, and the Stablecoin (SSC) stayed backed by enough collateral.

Q--yaha pe to dekho system ko to loss ho hi nahi raha hai suppose 1800 hua to 2 eth girvi the to 3600  worth hai abhi system ke pass and usne user ko diya hai 2000 agar user bhag bhi gaya to system ko to koi loss hai hi nahi  ?
  You are absolutely right! As long as the ETH price stays above $1,000, the system is technically safe because Alice's 2 ETH are still worth more than her $2,000 debt.

However, the reason we need Liquidation and users like Bob is to ensure the system never even gets close to that "Insolvency Line." Think of it like this:

1. The "Safety Cushion"
The system only gave Alice $2,000 when she deposited $5,000. This $3,000 gap is a Cushion. It exists because crypto prices are extremely volatile. The cushion gives the system "room to breathe" if the market drops overnight.

2. The Real Threat: The "Flash Crash"
Imagine ETH doesn't stop at $1,800. What if it suddenly crashes to $900 in a few minutes?

Alice’s Debt: $2,000.
Alice’s Gold (2 ETH): Worth only $1,800 (2 * $900).
The Result: Now the system is at a Loss. If Alice "runs away" (which she essentially does in DeFi), she has $2,000 in her pocket while the system only has $1,800 left. The stablecoin would lose its peg and the system would go "Insolvent" (Bankrupt).
3. Bob’s Role: The "Preventive Strike"
Bob’s job is to ensure we never hit the $1,000 "Death Line."

As soon as the price hits $1,800 (nearing the danger zone), Bob starts cleaning up (Liquidating).
The 10% Bonus is Bob’s motivation to act fast. Without a bonus, Bob might wait too long, and by the time he acts, the ETH price might have already fallen below the debt amount.
4. What if the user runs away?
In DeFi, the user is already "gone." There is no KYC (identity check). Alice has the $2,000 SSC tokens and can spend them anywhere.

The system doesn't care about Alice's face or name.
It only cares about her ETH collateral.
The system relies entirely on Bob to pay back the debt (burning the SSC) and sell the ETH before its value drops below the debt.

  */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from
    "../lib/foundry-chainlink-toolkit/lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract SingleAssetStableCoin is ERC20, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // ------------------ ❌ CUSTOM ERRORS ------------------
    error AmountMustBeMoreThanZero();
    error BurnAmountExceedsBalance();
    error NotZeroAddress();
    error NeedsMoreThanZero();
    error TransferFailed();
    error BreaksHealthFactor(uint256 healthFactorValue);
    error MintFailed();
    error HealthFactorOk();
    error HealthFactorNotImproved();

    // ------------------ ⛓️ IMMUTABLES ------------------
    address private immutable ETH_PRICE_FEED;

    // ------------------ ⚔️ THE RULES OF THE BATTLEFIELD (CONSTANTS) ------------------

    /**
     * @dev 🛡️ THE SHIELD: 50%.
     * Alice has $5,000 ETH. Guard says: "You can only borrow $2,500 SSC."
     */
    uint256 private constant LIQUIDATION_THRESHOLD = 50; 
    
    /**
     * @dev 🐺 THE HUNTER'S BOUNTY: 10%.
     * Alice fails. Bob pays her $1,000 debt. Bob gets $1,100 worth of her ETH.
     */
    uint256 private constant LIQUIDATION_BONUS = 10; 
    
    // Scale for percentage math (100 = 100%)
    uint256 private constant LIQUIDATION_PRECISION = 100;
    
    // The Line of Death (Health Factor < 1.0)
    uint256 private constant MIN_HEALTH_FACTOR = 1e18;
    
    // Standard WEI Scale
    uint256 private constant PRECISION = 1e18;
    
    // Translates 8-decimal Price Feed to our 18-decimal Contract.
    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;

    // ------------------ 📊 THE LEDGER (STATE) ------------------
    // Alice's ETH balance in WEI (e.g., 2 * 10^18)
    mapping(address => uint256) private collateralDeposited; 
    
    // Alice's SSC debt in WEI (e.g., 2000 * 10^18)
    mapping(address => uint256) private sscMinted;

    // ------------------ 🔔 EVENTS ------------------
    event CollateralDeposited(address indexed user, uint256 indexed amount);
    event CollateralRedeemed(address indexed redeemFrom, address indexed redeemTo, uint256 amount);
    event SSCMinted(address indexed user, uint256 indexed amount);
    event SSCBurned(address indexed user, uint256 indexed amount);

    // 🛡️ Ensure no one passes "0" as gold or debt.
    modifier moreThanZero(uint256 amount) {
        if (amount == 0) revert NeedsMoreThanZero();
        _;
    }

    // ------------------ 🏗️ CONSTRUCTOR ------------------
    constructor(address ethUSDPriceFeedAddress) ERC20("SingleAssetStableCoin", "SSC") Ownable(msg.sender) {
        ETH_PRICE_FEED = ethUSDPriceFeedAddress;
    }

    // ------------------ 👤 USER ACTIONS: THE JOURNEY BEGINS ------------------

    /**
     * @notice 🚩 **FLOW: ALICE ENTERS (PART 1)**
     * Alice calls this with `amountSscToMint = 2000e18` ($2,000) and `msg.value = 2 ether`.
     * 
     * ⏩ JUMP 1: Go to _depositCollateral() to lock her 2 ETH.
     * ⏩ JUMP 2: Go to _mintSsc() to get her $2,000 tokens.
     */
    function depositCollateralAndMintSsc(uint256 amountSscToMint) external payable {
        // Step 1: Alice sends 2 ETH ($5,000 value). 
        // Logic: Contract keeps the ETH and updates Alice's ledger.
        _depositCollateral();

        // Step 2: Alice asks for 2,000 SSC ($2,000 value).
        // Logic: Check if $2,000 debt is supported by $5,000 collateral.
        // Calculation: (5000 * 50%) / 2000 = 1.25 HP (Health Factor). 1.25 > 1.0, so proceed!
        _mintSsc(amountSscToMint);
    }

    /**
     * @notice 🚩 **FLOW: ALICE RECOVERS (Voluntary)**
     * Alice wants her 1 ETH back, so She pays back $1,000 SSC.
     * 
     * ⏩ JUMP 1: _burnSsc(1000) -> Deletes her debt. New Debt = $1,000.
     * ⏩ JUMP 2: _redeemCollateral(1 ether) -> Releases 1 ETH. New Collateral = 1 ETH.
     * ⏩ JUMP 3: Check Health -> (1 ETH * $2500 * 0.5) / $1000 = 1.25. (SAFE!🏰).
     */
    function redeemCollateralForSsc(uint256 amountCollateral, uint256 amountSscToBurn)
        external
        moreThanZero(amountCollateral)
        moreThanZero(amountSscToBurn)
        nonReentrant
    {
        // Step 1: Alice hands back $1,000 SSC to the bank.
        // Effect: sscMinted[Alice] decreases from 2000 to 1000.
        _burnSsc(amountSscToBurn, msg.sender);

        // Step 2: Alice takes back 1 ETH ($2,500 value).
        // Effect: collateralDeposited[Alice] decreases from 2 ETH to 1 ETH.
        _redeemCollateral(amountCollateral, msg.sender, msg.sender);

        // Step 3: Security Check.
        // New Calculation: Collateral = $2,500 (1 ETH), Debt = $1,000.
        // Health Factor: (2500 * 50%) / 1000 = 1.25. Still safe!
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    /**
     * @notice 🚩 **FLOW: ALICE WITHDRAWS EXCESS GOLD**
     * Alice wants to pull out 0.2 ETH without paying debt.
     * 
     * ⏩ JUMP 1: _redeemCollateral(0.2 ether) -> Sends ETH back to her.
     * ⏩ JUMP 2: Check Health -> (1.8 ETH * $2500 * 0.5) / $2000 = 1.125. (SAFE!🏠).
     * If She tried to withdraw 1 ETH, health would be 0.625 and the GUARD would REVERT!
     */
    function redeemCollateral(uint256 amountCollateral) external moreThanZero(amountCollateral) nonReentrant {
        // Example: Alice has 2 ETH ($5,000) and $2,000 debt.
        // Alice tries to withdraw 0.5 ETH ($1,250).
        _redeemCollateral(amountCollateral, msg.sender, msg.sender);

        // Security Check:
        // Remaining Collateral: 1.5 ETH = $3,750. Debt = $2,000.
        // Calculation: (3750 * 50%) / 2000 = 1875 / 2000 = 0.9375.
        // ACTION: This will REVERT because HF < 1.0!
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    /**
     * @notice 🚩 **FLOW: ALICE RE-FORGES HER SHIELD**
     * Alice burns $500 SSC just to increase her safety multiplier.
     * 
     * ⏩ JUMP 1: _burnSsc(500) -> Debt = $1500.
     * ⏩ JUMP 2: Check Health -> (5000 * 0.5) / 1500 = **1.66**. (VERY SAFE!🛡️).
     */
    function burnSsc(uint256 amount) external moreThanZero(amount) nonReentrant {
        // Alice has $2,000 debt. She burns $500 SSC.
        // Effect: Alice's liability drops to $1,500.
        _burnSsc(amount, msg.sender);

        // Security Check:
        // Result: Her Health Factor increases (makes her safer).
        // Calculation: (2500 / 1500) = 1.66 HF.
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    /**
     * @notice ⚡ **FLOW: BOB THE BOUNTY HUNTER STRIKES (PART 4)**
     * Alice's ETH price falls to **$1,800**. Her shield breaks (Health = 0.9).
     * Bob smells the bounty! He calls `liquidate(alice, 1000e18)`.
     * 
     * ⏩ JUMP 1: Check Alice Health -> 0.9. (It's < 1.0, so the hunt is ON).
     * ⏩ JUMP 2: Convert $1,000 Debt to ETH -> ($1000 / $1800) = **0.555 ETH**.
     * ⏩ JUMP 3: Add 10% Bounty -> 0.555 + 0.055 = **0.611 ETH total reward**.
     * ⏩ JUMP 4: Give 0.611 ETH to Bob from Alice's vault.
     * ⏩ JUMP 5: Delete $1,000 from Alice's debt ledger.
     * ⏩ JUMP 6: New Alice Health = (1.389 ETH * $1800 * 0.5) / $1000 = **1.25** (SAFE!).
     */
    function liquidate(address user, uint256 debtToCover) external moreThanZero(debtToCover) nonReentrant {
        //debtToCover-token amount of ssc to be liquidated
        // Step 1: Check if User is actually failing.
        uint256 startingHealthFactor = _healthFactor(user);
        if (startingHealthFactor >= MIN_HEALTH_FACTOR) revert HealthFactorOk();

        // Step 2: Calculate how much ETH is needed to cover $1,000 debt.
        // If ETH = $1,800, then $1000 debt = 0.555 ETH.
        uint256 tokenAmountFromDebt = getTokenAmountFromUsd(debtToCover);

        // Step 3: Calculate Bob's 10% tip. 
        // 10% of 0.555 ETH = 0.055 ETH.
        uint256 bonusCollateral = (tokenAmountFromDebt * LIQUIDATION_BONUS) / LIQUIDATION_PRECISION;

        // Step 4: Total payout to Bob = 0.555 + 0.055 = 0.611 ETH.
        uint256 totalCollateralToRedeem = tokenAmountFromDebt + bonusCollateral;

        // Step 5: Transfer the "Prize" from Alice to Bob.
        _redeemCollateral(totalCollateralToRedeem, user, msg.sender);

        // Step 6: Wipe $1,000 from Alice's debt ledger.
        _burnSsc(debtToCover, user);

        // Step 7: Final Check. Did Alice's health actually get better?
        uint256 endingHealthFactor = _healthFactor(user);
        if (endingHealthFactor <= startingHealthFactor) revert HealthFactorNotImproved();

        // Step 8: Ensure the Hunter (Bob) didn't break his own health factor in the process.
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    // ------------------ 🧊 THE ENGINE ROOM (INTERNAL) ------------------

    /**
     * @dev 🚂 **MINTING SUB-FLOW:**
     * 📝 Alice Ledger: Increase `sscMinted` by 2000.
     * ⏩ JUMP: Check if she hit the $2,500 safety wall. If Price crashed mid-transaction, REVERT.
     */
    function _mintSsc(uint256 amountSscToMint) internal moreThanZero(amountSscToMint) nonReentrant {
        // Add to internal debt ledger.
        sscMinted[msg.sender] += amountSscToMint;

        // If Alice has $5000 collateral and tries to mint $6000 SSC, this guard stops her.
        _revertIfHealthFactorIsBroken(msg.sender);

        // Create the actual ERC20 tokens in Alice's wallet.
        _mint(msg.sender, amountSscToMint);
        emit SSCMinted(msg.sender, amountSscToMint);
    }

    /**
     * @dev 🚂 **DEPOSIT SUB-FLOW:**
     * 📝 Alice Ledger: Increase `collateralDeposited` by 2 ETH.
     */
    function _depositCollateral() internal nonReentrant {
        uint256 amountCollateral = msg.value;
        if (amountCollateral == 0) revert NeedsMoreThanZero();

        // Increment Alice's "Savings Account" in the contract.
        collateralDeposited[msg.sender] += amountCollateral;
        emit CollateralDeposited(msg.sender, amountCollateral);
    }

    /**
     * @dev 🚂 **REDEEM SUB-FLOW:**
     * 📝 Alice Ledger: Decrease her gold by `totalCollateralToRedeem` (0.611 ETH in Bob's hunt).
     * 🏧 Payout: Transfer actual ETH from this contract's vault to Bob's wallet.
     */
    function _redeemCollateral(uint256 amountCollateral, address from, address to) private {
        // Ensure Alice has enough balance to withdraw.
        if (amountCollateral > collateralDeposited[from]) revert AmountMustBeMoreThanZero();

        // Deduct from ledger.
        collateralDeposited[from] -= amountCollateral;
        emit CollateralRedeemed(from, to, amountCollateral);

        // Perform physical ETH transfer from the contract to the receiver.
        (bool success,) = payable(to).call{value: amountCollateral}("");
        if (!success) revert TransferFailed();
    }

    /**
     * @dev 🚂 **BURN SUB-FLOW:**
     * 📝 Alice Ledger: Decrease her debt by 1000.
     * 🔥 Destruction: Move tokens from user back to contract and DELETE them forever.
     */
    function _burnSsc(uint256 amountSscToBurn, address from) private {
        // Ensure the person has the debt they claim to be paying.
        if (amountSscToBurn > sscMinted[from]) revert AmountMustBeMoreThanZero();

        // Deduct from debt ledger.
        sscMinted[from] -= amountSscToBurn;

        // Move tokens from user back to contract.
        IERC20(address(this)).safeTransferFrom(from, address(this), amountSscToBurn);

        // Physically delete/burn the tokens.
        _burn(address(this), amountSscToBurn);
        emit SSCBurned(from, amountSscToBurn);
    }

    // ------------------ 🧩 THE BRAINS (MATH) ------------------

    /**
     * @dev 🧠 **SAFETY ANALYZER:**
     * Steps into Alice's account info. 
     * Pulls Debt ($2000) and Gold ($5000). 
     * ⏩ JUMP: Hand data to `_calculateHealthFactor`.
     */
    function _healthFactor(address user) private view returns (uint256) {
        // Step 1: How much debt? (e.g. $2,000)
        // Step 2: How much gold? (e.g. $5,000)
        (uint256 totalSsc, uint256 collateralValueUsd) = _getAccountInformation(user);

        // Step 3: Run the calculation.
        return _calculateHealthFactor(totalSsc, collateralValueUsd);
    }

    /**
     * @dev 🧠 **THE DECODER RING (PRICE FEED):**
     * 🧮 CALC: Price = 2500 * 10^8. 
     * Multiply by 10^10 = 2500 * 10^18. 
     * Multiply by Alice's 2 ETH = 5000 * 10^18 USD ($5,000 in WEI).
     */
    function _getUsdValue(uint256 amount) private view returns (uint256) {
        (, int256 price,,,) = AggregatorV3Interface(ETH_PRICE_FEED).latestRoundData();
        return ((uint256(price) * ADDITIONAL_FEED_PRECISION) * amount) / PRECISION;
    }

    /**
     * @dev 🧠 **THE SAFETY FORMULA:**
     * ⚖️ (Collateral $5000 * Threshold 50%) / Debt $2000 = **1.25 Score.**
     */
    function _calculateHealthFactor(uint256 totalSsc, uint256 collateralValueUsd) internal pure returns (uint256) {
        // If no debt, you are infinitely safe!
        if (totalSsc == 0) return type(uint256).max; 

        // 1. Apply the 50% Safety Filter. 
        // $5,000 ETH * 50% = $2,500 (The "Borrowing Power").
        uint256 collateralAdjusted = (collateralValueUsd * LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION;

        // 2. Divide Power by Debt.
        // $2,500 / $2,000 = 1.25 HP.
        return (collateralAdjusted * PRECISION) / totalSsc;
    }

    /**
     * @dev 🧱 **THE DEFI WALL:**
     * Alice tried to withdraw too much Gold? Health becomes 0.9.
     * **ERROR: BreaksHealthFactor(0.9e18)** triggered. Whole journey cancels!
     */
    function _revertIfHealthFactorIsBroken(address user) internal view {
        uint256 healthFactor = _healthFactor(user);
        if (healthFactor < MIN_HEALTH_FACTOR) {
            revert BreaksHealthFactor(healthFactor);
        }
    }

    // ------------------ 🌐 EXTERNAL READERS ------------------

    function _getAccountInformation(address user) private view returns (uint256 totalSsc, uint256 collateralValueUsd) {
        totalSsc = sscMinted[user];
        collateralValueUsd = getAccountCollateralValue(user);
    }

    function getTokenAmountFromUsd(uint256 usdAmountInWei) public view returns (uint256) {
        // Question: How much ETH covers $1,000?
        // Answer: $1,000 / Price-of-ETH.
        // Calculation: ($1,000 * 1e18) / ($1,800 * 1e18) = 0.555 ETH.
        (, int256 price,,,) = AggregatorV3Interface(ETH_PRICE_FEED).latestRoundData();
        return ((usdAmountInWei * PRECISION) / (uint256(price) * ADDITIONAL_FEED_PRECISION));
    }

    function getHealthFactor(address user) external view returns (uint256) { return _healthFactor(user); }
    function getAccountCollateralValue(address user) public view returns (uint256) { return _getUsdValue(collateralDeposited[user]); }
    function getAccountInformation(address user) external view returns (uint256 totalSsc, uint256 collateralValueUsd) { return _getAccountInformation(user); }

    receive() external payable {}
}
