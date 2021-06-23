//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IAssetListHolder.sol";
import "./interfaces/IAssetHolder.sol";
import "./interfaces/IAuditorPoolFactory.sol";
import "./interfaces/IAuditorPool.sol";
import "./shared/Structs.sol";

contract APXCoordinator is Ownable {

    // FACTORIES
    address public auditorPoolFactory;

    // ASSET TYPES
    AssetType[] public assetTypesList;
    mapping(uint256 => AssetType) public assetTypes;
    
    // AUDITOR POOLS
    AuditorPool[] public auditorPools;

    // ASSETTYPE-TO-POOL HOLDER
    mapping(uint256 => uint256) public assetTypeToPool;

    address public assetListHolder;
    address public stakingToken;

    // PROTOCOL PROPERTIES
    uint256 public auditGapDuration;
    uint256 public auditDuration;
    uint256 public councilSize;
    uint256 public minPersonalStake;
    uint256 public minStakeToQualify;
    uint256 public maxNumberOfAuditors;

    event AssetListed(address indexed tokenizedAsset);

    constructor(
        address _assetListHolder,
        uint256 _auditGapDuration,
        uint256 _auditDuration,
        uint256 _councilSize,
        uint256 _minPersonalStake,
        uint256 _minStakeToQualify,
        uint256 _maxNumberOfAuditors,
        address _stakingToken,
        address _auditorPoolFactory
    ) {
        assetListHolder = _assetListHolder;
        auditGapDuration = _auditGapDuration;
        auditDuration = _auditDuration;
        councilSize = _councilSize;
        minPersonalStake = _minPersonalStake;
        minStakeToQualify = _minStakeToQualify;
        maxNumberOfAuditors = _maxNumberOfAuditors;
        stakingToken = _stakingToken;
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
        uint256 assetTypeId,
        address tokenizedAsset,
        string memory name,
        string memory info,
        string memory listingInfo
    ) external {
        IAssetListHolder(assetListHolder).addAsset(
            name,
            assetId,
            procedureId,
            auditorPoolId,
            tokenizedAsset,
            additionalInfo
        );
        emit AssetListed(tokenizedAsset);
    }

    function startAudit(uint256 assetIndex) external {
        IAssetHolder asset = IAssetHolder(IAssetListHolder(assetListHolder).assets(assetIndex));
        uint256 lastAuditTimestamp = asset.getLatestAudit().timestamp;
        uint256 auditorPoolId = asset.getDescriptor().auditorPoolId;
        
        require(
            lastAuditTimestamp == 0 || ((block.timestamp - lastAuditTimestamp) >= auditGapDuration),
            "Asset not ready for audit."  
        );
        require(
            
        );
        uint256 councilId = IAuditorPool(auditorPools[auditorPoolId]).requestCouncil(councilSize);
    }

}
