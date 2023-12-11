const {ethers, network } = require("hardhat");
const hre = require ("hardhat");

async function main() {
    const Token = await hre.ethers.getContractFactory("Token");
    console.log("Deploying Token contract...");
    const token = await Token.deploy("myToken", "myT1", 1000000);
    await token.deployed();
    console.log ("Token contract deployed @:", token.address);

    const SimpleDex = await hre.ethers.getContractFactory("SimpleDEX");
    console.log ("Deploying SimpleDex contract...");
    const simpleDex = await SimpleDex.deploy(token.address, "@xD4a33860578De61DBAbDc8BFdb98FD742fA7028e");
    await simpleDex.deployed();
    console.log ("SimpleDex contract deployed @:", simpleDex.address);

    const Treasury = await hre.ethers.getContractFactory("Treasury");
    console.log ("Deploying SimpleDex contract...");
    const treasury = await Treasury.deploy(simpleDex.address);
    await treasury.deployed();
    console.log ("Treasury contract deployed @:", treasury.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });