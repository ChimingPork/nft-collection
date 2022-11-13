const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env"});
const { WHITELIST_CONTRACT_ADDRESS, METADATA_URL }  = require("../constants");

async function main() {
  //Address of the whitelist contract that was deployed in previous module
  const whitelistContract = WHITELIST_CONTRACT_ADDRESS;
  //URL from where we can extract the metadata for a Crypto Dev NFT
  const metadataURL = METADATA_URL;

  //Contract factory is used to deploy new SC in ethers.js
  //cryptoDevsContract is a factory for instances of CryoDevs contract
  const cryptoDevsContract = await ethers.getContractFactory("CryptoDevs");

  //Deploy the contract
  const deployedCryptoDevsContract = await cryptoDevsContract.deploy(
    metadataURL,
    whitelistContract
  );

  //print the contract address
  console.log(
    "Crypto Devs Contract Address:",
    deployedCryptoDevsContract.address
  );
}

//Call the main function and catch if there is any error
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });