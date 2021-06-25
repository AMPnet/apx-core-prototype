//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IAssetListHolder.sol";
import "./interfaces/IAssetHolder.sol";
import "./interfaces/IAuditorPool.sol";
import "./shared/Structs.sol";

contract APXCoordinator is Ownable {
    using SafeERC20 for IERC20;

    // ASSET TYPES
    AssetType[] public assetTypesList;
    mapping(uint256 => AssetType) public assetTypes;
    
    // AUDITOR POOLS
    AuditorPool[] public auditorPools;

    // ASSETTYPE-TO-POOL HOLDER
    mapping(uint256 => uint256) public assetTypeToPool;

    // ASSETS
    address public assetListHolder;

    // PROTOCOL PROPERTIES
    IERC20 public stablecoin;
    uint256 public auditGapDuration;
    uint256 public usdcPerAudit = 10 * (10**18);
    uint256 public usdcPerList = 10 * (10**18);
    uint256 public protocolFeePercentage = 3;

    event AssetListed(address indexed tokenizedAsset);

    constructor(
        address _assetListHolder,
        IERC20 _stablecoin,
        uint256 _auditGapDuration
    ) {
        assetListHolder = _assetListHolder;
        stablecoin = _stablecoin;
        auditGapDuration = _auditGapDuration;
    }

    modifier auditorEligibleForAssetType(uint256 typeId) {
        uint256 poolId = assetTypeToPool[typeId];
        AuditorPool storage pool = auditorPools[poolId];
        Auditor storage auditor = pool.auditors[msg.sender];
        require(
            pool.active,
            "Pool not active."
        );
        require(
            auditor.registered,
            "Auditor not registered in this pool."
        );
        require(
            auditor.active,
            "Auditor not active in this pool."
        );
        _;
    }

    function createNewAssetType(
        string memory name,
        string memory info
    ) external onlyOwner returns (uint256) {
        uint256 assetTypeId = assetTypesList.length;
        AssetType storage assetType = assetTypesList.push();
        assetType.id = assetTypeId;
        assetType.name = name;
        assetType.info = info;
        return assetTypeId;
    }

    function createNewAuditorPool(
        string memory name,
        string memory info
    ) external onlyOwner returns (uint256) {
        uint256 auditorPoolId = auditorPools.length;
        AuditorPool storage pool = auditorPools.push();
        pool.id = auditorPoolId;
        pool.name = name;
        pool.info = info;
        return auditorPoolId;
    }

    function addAuditorToPool(
        uint256 poolId,
        address auditorAddress,
        string memory auditorInfo
    ) external onlyOwner returns (bool) {
        require(
            poolId < auditorPools.length,
            "Invalid pool id."
        );
        require(
            poolId >= 0,
            "Invalid pool id."
        );
        require(
            !auditorPools[poolId].auditors[auditorAddress].registered,
            "Auditor already member of the pool."
        );
        AuditorPool storage pool = auditorPools[poolId];
        Auditor storage auditorHolder = pool.auditorsList.push();
        auditorHolder.auditor = auditorAddress;
        auditorHolder.info = auditorInfo;
        auditorHolder.registered = true;
        auditorHolder.active = true;
        pool.auditors[auditorAddress] = auditorHolder;
        if (pool.auditorsList.length > 0) {
            pool.active = true;
        }
        pool.activeMembers += 1;
        return true;
    }

    function assignAssetTypeToPool(
        uint256 assetTypeId,
        uint256 poolId
    ) external onlyOwner returns(bool) {
        assetTypeToPool[assetTypeId] = poolId;
        return true;
    }

    function listAsset(
        address tokenizedAsset,
        uint256 typeId,
        string memory name,
        string memory ticker,
        string memory info,
        string memory listingInfo
    ) external auditorEligibleForAssetType(typeId) {
        IERC20 stablecoinToken = IERC20(stablecoin);
        require(
            stablecoinToken.balanceOf(tokenizedAsset) >= usdcPerList,
            "Asset balance too low to list."
        );
        stablecoinToken.safeTransferFrom(tokenizedAsset, msg.sender, usdcPerList);
        IAssetListHolder(assetListHolder).addAsset(
            tokenizedAsset,
            msg.sender,
            typeId,
            name,
            ticker,
            info,
            listingInfo
        );
    }

    function performAudit(
        uint256 assetId,
        bool assetValid,
        string memory additionalInfo
    ) external auditorEligibleForAssetType(getAssetByAssetId(assetId).typeId()) {
        IAssetHolder asset = getAssetByAssetId(assetId);
        address tokenizedAsset = asset.tokenizedAsset();
        Auditor storage auditor = getCallerAuditorByAssetId(assetId);
        require(
            (block.timestamp - asset.getLatestAudit().timestamp) >= auditGapDuration,
            "New audit not yet required."
        );
        require(
            stablecoin.balanceOf(tokenizedAsset) >= usdcPerAudit,
            "Asset balance to low to audit."
        );
        stablecoin.safeTransferFrom(tokenizedAsset, msg.sender, usdcPerAudit);
        asset.performAudit(assetValid, additionalInfo);
        auditor.totalAuditsPerformed += 1;
    }

    function setStablecoin(IERC20 _stablecoin) external {
        stablecoin = _stablecoin;
    }

    function getCallerAuditorByAssetId(uint256 assetId) private view returns (Auditor storage) {
        return auditorPools[
            getAssetByAssetId(assetId).typeId()
        ].auditors[msg.sender];
    }

    function getAssetByAssetId(uint256 assetId) private view returns (IAssetHolder) {
        return IAssetHolder(IAssetListHolder(assetListHolder).assets(assetId));
    }

}
