// const { ethers, upgrades } = require("hardhat");
// const PROXY_ADDR = "0xa8751B3E8B176E372cEb58FECEbC52dBF8AA9795";

// async function main() {
//   const BoxV3 = await ethers.getContractFactory("BoxV3");

//   // Upgrade the proxy to BoxV3
//   await upgrades.upgradeProxy(PROXY_ADDR, BoxV3);

//   // Get the implementation address using the admin
//   const implementationAddress = await upgrades.erc1967.getImplementationAddress(
//     PROXY_ADDR
//   );

//   console.log("Box Upgraded to V2");
//   console.log("Upgraded implementation address:", implementationAddress);
// }

// // Execute the main function and catch any errors
// main().catch((error) => {
//   console.error(error);
//   process.exit(1);
// });
const { ethers, upgrades } = require("hardhat");

// MAKE SURE THIS IS YOUR ACTUAL PROXY ADDRESS
const PROXY_ADDR = "0x264aBF4B067022491E6DF75457317F20D491a6Dd";

async function main() {
  const BoxV3 = await ethers.getContractFactory("BoxV3");

  console.log("Upgrading Box to V3...");

  // upgradeProxy khud hi transaction mine hone ka wait karta hai
  const upgraded = await upgrades.upgradeProxy(PROXY_ADDR, BoxV3);

  console.log("Waiting for block state to sync...");
  // 15-20 seconds wait karte hain taaki RPC node update ho jaye
  await new Promise((resolve) => setTimeout(resolve, 20000));

  const implementationAddress = await upgrades.erc1967.getImplementationAddress(
    PROXY_ADDR,
  );

  console.log("✔ Box Upgraded to V3 successfully!");
  console.log("New Implementation address:", implementationAddress);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});

//yeh kiya tha ki implementation update nahi aa raha tha sahi se.
