const { ethers, upgrades } = require("hardhat");
const PROXY_ADDR = "0xa8751B3E8B176E372cEb58FECEbC52dBF8AA9795";

async function main() {
  const BoxV5 = await ethers.getContractFactory("BoxV5");

  // Upgrade the proxy to BoxV3
  await upgrades.upgradeProxy(PROXY_ADDR, BoxV5);

  // Get the implementation address using the admin
  const implementationAddress = await upgrades.erc1967.getImplementationAddress(
    PROXY_ADDR
  );

  console.log("Box Upgraded to V5");
  console.log("Upgraded implementation address:", implementationAddress);
}

// Execute the main function and catch any errors
main().catch((error) => {
  console.error(error);
  process.exit(1);
});
