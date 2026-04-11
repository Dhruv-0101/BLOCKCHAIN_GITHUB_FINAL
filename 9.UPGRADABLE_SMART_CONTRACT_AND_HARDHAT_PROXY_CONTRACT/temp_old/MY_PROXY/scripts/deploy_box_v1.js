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
Proxy contract address: 0xa8751B3E8B176E372cEb58FECEbC52dBF8AA9795
Implementation contract address: 0x99526Db91c58061431f778d7e9d0D90441f58351
Admin contract address: 0x856D3E8809eD29f7B3beD93bb552D36157C23d3f
*/