const { ethers, upgrades } = require("hardhat");
const PROXY_ADDR = "0xa8751B3E8B176E372cEb58FECEbC52dBF8AA9795";

async function main() {
  const BoxV4 = await ethers.getContractFactory("BoxV4");

  // Upgrade the proxy to BoxV3
  await upgrades.upgradeProxy(PROXY_ADDR, BoxV4);

  // Get the implementation address using the admin
  const implementationAddress = await upgrades.erc1967.getImplementationAddress(
    PROXY_ADDR
  );

  console.log("Box Upgraded to V2");
  console.log("Upgraded implementation address:", implementationAddress);
}

// Execute the main function and catch any errors
main().catch((error) => {
  console.error(error);
  process.exit(1);
});
