//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IAssetListHolder.sol";
import "./interfaces/IAssetHolder.sol";
import "./interfaces/IAuditorPool.sol";
import "./shared/Structs.sol";

contract APXCoordinator is Ownable {

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
    uint256 public auditGapDuration;
    uint256 public aapxPerAudit;
    uint256 public aapxPerList;

    event AssetListed(address indexed tokenizedAsset);

    constructor(
        address _assetListHolder,
        uint256 _auditGapDuration
    ) {
        assetListHolder = _assetListHolder;
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
        Auditor storage auditor = getCallerAuditorByAssetId(assetId);
        require(
            (block.timestamp - asset.getLatestAudit().timestamp) >= auditGapDuration,
            "New audit not yet required."
        );
        asset.performAudit(assetValid, additionalInfo);
        auditor.totalAuditsPerformed += 1;
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
