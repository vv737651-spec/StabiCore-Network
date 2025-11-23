const { ethers } = require("hardhat");

async function main() {
  const StabiCoreNetwork = await ethers.getContractFactory("StabiCoreNetwork");
  const stabiCoreNetwork = await StabiCoreNetwork.deploy();

  await stabiCoreNetwork.deployed();

  console.log("StabiCoreNetwork contract deployed to:", stabiCoreNetwork.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
