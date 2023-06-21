const hre = require("hardhat");

async function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main() {
  
  const tokenContract = await hre.ethers.deployContract("LpToken");
  await tokenContract.deployed();
  console.log("Token deployed to:", tokenContract.address);

  const exchangeContract = await hre.ethers.deployContract("Exchange", [
    tokenContract.address,
  ]);
  await exchangeContract.deployed();
  console.log("Exchange deployed to:", exchangeContract.address);

  await sleep(30 * 1000);

  await hre.run("verify:verify", {
    address: tokenContract.address,
    constructorArguments: [],
    contract: "contracts/LpToken.sol:LpToken",
  });

  await hre.run("verify:verify", {
    address: exchangeContract.address,
    constructorArguments: [tokenContract.address],
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});