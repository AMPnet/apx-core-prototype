import { ethers } from "hardhat"

describe("ERC20", () => {
    it("should have a balance", async () => {
        const Greeter = await ethers.getContractFactory("Greeter")
        const greeter = await Greeter.deploy()
        await greeter.deployed()

        
    })
})