const { ethers, upgrades } = require("hardhat");

async function main() {
  const Vote = await ethers.getContractFactory("Vote");

  // Deploy the proxy with the `initialize` initializer
  const proxyContract = await upgrades.deployProxy(Vote, [], {
    initializer: "initialize",
  });

  await proxyContract.waitForDeployment();

  const proxyAddress = await proxyContract.getAddress();
  const implementationAddress = await upgrades.erc1967.getImplementationAddress(
    proxyAddress
  );
  const adminAddress = await upgrades.erc1967.getAdminAddress(proxyAddress);

  console.log("✅ Proxy deployed at:", proxyAddress);
  console.log("📦 Implementation address:", implementationAddress);
  console.log("🛠 Admin address:", adminAddress);
}

main().catch((error) => {
  console.error("❌ Deployment failed:", error);
  process.exit(1);
});
/*
✅ Proxy deployed at: 0xe8f76E6D632118C40af0702F6fb85f7133650Cc1
📦 Implementation address: 0x50c19cdd5a150EaB1ec099E3f8a97c521De3E151
🛠 Admin address: 0x93d56517579FD42ef02C2861EA462a37164b0582

✅ Proxy deployed at: 0x62a4Acbcba665A6A1176d424Ef557c182A40b884
📦 Implementation address: 0x50c19cdd5a150EaB1ec099E3f8a97c521De3E151
🛠 Admin address: 0x24006f6FcB44FCC34094C3b78D9ae3d100598A6A
*/