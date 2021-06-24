import { ethers } from "hardhat";
import { Contract, ContractFactory, Signer } from "ethers";

const factories: Map<String, ContractFactory> = new Map();

export async function deployToken(deployer: Signer, supply: string): Promise<Contract> {
    const supplyWei = ethers.utils.parseEther(supply);
    const Token = await ethers.getContractFactory("Token", deployer);
    const token = await Token.deploy(supplyWei);
    console.log(`Token deployed at: ${token.address}`);
    factories[token.address] = Token.interface;
    return token;
}
