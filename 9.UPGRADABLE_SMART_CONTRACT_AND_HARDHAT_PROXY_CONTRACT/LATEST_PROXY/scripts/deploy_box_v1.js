const { ethers, upgrades } = require('hardhat');

async function main () {
  const Box = await ethers.getContractFactory('Box');
 
  const proxyContract = await upgrades.deployProxy(Box, [768], {
    initializer: "setValue"
  });

  await proxyContract.waitForDeployment();

  const proxyContractAddress = await proxyContract.getAddress();
  const implementationAddress = await upgrades.erc1967.getImplementationAddress(proxyContractAddress);
  const adminAddress = await upgrades.erc1967.getAdminAddress(proxyContractAddress);

  console.log("Proxy contract address:",proxyContractAddress)
  console.log("Implementation contract address:", implementationAddress);
  console.log("Admin contract address:", adminAddress);
}

// Execute the main function and catch any errors
main().catch((error) => {
  console.error(error);
  process.exit(1);
});

/*
Proxy contract address: 0x264aBF4B067022491E6DF75457317F20D491a6Dd
Implementation contract address: 0x806f3db3F33F7d9eF257D555ffD7eb03A6443797
Admin contract address: 0xA92689b0D0edde5a9124351E1DdC1bC16b004e58
*/