import { ethers } from "hardhat";
import { Contract, Signer } from "ethers";
import { expect } from "chai";
import * as helpers from "../util/helpers";

describe("Full test", function () {

    let deployer: Signer;
    let auditor: Signer;
    let usdc: Contract;
    let tokenizedAsset: Contract;

    this.beforeEach(async function () {
        const accounts: Signer[] = await ethers.getSigners();
        deployer = accounts[0];
        auditor = accounts[1];
        usdc = await helpers.deployToken(deployer, "7000000");
        tokenizedAsset = await helpers.deployToken(deployer, "70000000");
    });

    it(
        `should successfully complete fhe flow:\n
            1) deploy AssetListHolder\n
            2) deploy APXCoordinator\n
            3) create one AuditorPool\n
            4) add one Auditor to the AuditorPool\n
            5) Auditor lists the tokenized Asset\n
            6) Auditor audits the tokenized Asset once\n
            7) Shareholder mirrors his tokens to AAPX core
        `,
        async function () {
            const assetListHolder: Contract = await (await ethers.getContractFactory("AssetListHolder", deployer)).deploy();
            const apxCoordinator: Contract = await (await ethers.getContractFactory("APXCoordinator", deployer)).deploy(
                assetListHolder.address,
                usdc.address,
                1
            );
            const auditorAddress = await auditor.getAddress();
        
            await assetListHolder.setCoordinator(apxCoordinator.address);
            await apxCoordinator.setStablecoin(usdc.address);
            await apxCoordinator.createNewAuditorPool("Berlin Real Estate - 1", "ipfs-hash");
            await apxCoordinator.createNewAssetType("Berlin Real Estate - 1", "ipfs-hash");
            await apxCoordinator.addAuditorToPool(0, auditorAddress, "auditor-info-ipfs-hash");
            await apxCoordinator.assignAssetTypeToPool(0, 0);

            const tokenizedAssetFunds = ethers.utils.parseEther("20");
            await usdc.approve(tokenizedAsset.address, tokenizedAssetFunds);
            await tokenizedAsset.fundWallet(usdc.address, tokenizedAssetFunds, apxCoordinator.address);
            
            const assetName = "Mirrored Tokenized asset";
            const assetTicker = "MTA";
            const assetInfo = "info-ipfs-hash";
            const assetListingInfo = "listing-info-ipfs-hash";
            const assetTypeId = 0;
            await apxCoordinator.connect(auditor).listAsset(
                tokenizedAsset.address,
                assetTypeId,
                assetName,
                assetTicker,
                assetInfo,
                assetListingInfo
            );
            await apxCoordinator.connect(auditor).performAudit(
                0, true, "auditing-info-ipfs-hash"
            );
            const assetsList = await ethers.getContractAt("AssetListHolder", (await apxCoordinator.assetListHolder()));            
            const assets = await assetsList.getAssets();
            expect(assets).to.have.lengthOf(1);

            const assetDescriptor = await assetsList.getAssetById(0);
            expect(assetDescriptor.tokenizedAsset).to.be.equal(tokenizedAsset.address);
            expect(assetDescriptor.id).to.be.equal(0);
            expect(assetDescriptor.typeId).to.be.equal(assetTypeId);
            expect(assetDescriptor.name).to.be.equal(assetName);
            expect(assetDescriptor.ticker).to.be.equal(assetTicker);

            const asset = await ethers.getContractAt("AssetHolder", assetDescriptor.assetHolder);
            const latestAudit = await asset.getLatestAudit();
            expect(latestAudit.assetVerified).to.be.true;

            const listedBy = await asset.listedBy();
            expect(listedBy).to.be.equal(auditorAddress);
            
            const pool = await apxCoordinator.auditorPools(0);
            expect(pool.id).to.be.equal(0);
            expect(pool.active).to.be.true;
            expect(pool.activeMembers).to.be.equal(1);

            const sharesToMirror = ethers.utils.parseEther("1");
            await tokenizedAsset.connect(deployer).approve(asset.address, sharesToMirror);
            await asset.connect(deployer).claim();
            const mirroredShares = await asset.balanceOf(await deployer.getAddress());
            expect(mirroredShares).to.be.equal(sharesToMirror);

            const auditorBalance = await usdc.balanceOf(auditorAddress);
            expect(auditorBalance).to.be.equal(ethers.utils.parseEther("20"));
        }
    )

});
