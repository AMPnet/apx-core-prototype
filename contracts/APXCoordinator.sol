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
    
    // AUDITOR POOLS
    AuditorPool[] public auditorPools;
    mapping(uint256 => mapping(address => bool)) public poolRegisteredAuditorsMapping;
    mapping(uint256 => mapping(address => bool)) public poolActiveAuditorsMapping;
    mapping(uint256 => Auditor[]) poolAuditorsMapping;
    mapping(uint256 => mapping(address => uint256)) poolAuditorReference;
    mapping(address => uint256[]) public auditorPoolMemeberships;

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
        require(
            pool.active,
            "Pool not active."
        );
        require(
            poolActiveAuditorsMapping[poolId][msg.sender],
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
            !poolRegisteredAuditorsMapping[poolId][auditorAddress],
            "Auditor already member of the pool."
        );
        AuditorPool storage pool = auditorPools[poolId];
        Auditor[] storage auditorsList = poolAuditorsMapping[poolId];
        uint256 auditorIndex = auditorsList.length;
        Auditor storage auditorHolder = auditorsList.push();
        auditorHolder.auditor = auditorAddress;
        auditorHolder.info = auditorInfo;
        poolRegisteredAuditorsMapping[poolId][auditorAddress] = true;
        poolActiveAuditorsMapping[poolId][auditorAddress] = true;
        poolAuditorReference[poolId][auditorAddress] = auditorIndex;
        if (auditorsList.length > 0) {
            pool.active = true;
        }
        pool.activeMembers += 1;
        auditorPoolMemeberships[auditorAddress].push(poolId);
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
        Auditor storage auditor = getCallerAuditorByTypeId(typeId);
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
        auditor.totalListingsPerformed += 1;
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

    function getPoolMemberships(address auditor) external view returns (uint256[] memory) {
        return auditorPoolMemeberships[auditor];
    }

    function getPools() external view returns (AuditorPool[] memory) {
        return auditorPools;
    }

    function getPoolById(uint256 id) external view returns (AuditorPool memory) {
        return auditorPools[id];
    }

    function getPoolMembers(uint256 id) external view returns (Auditor[] memory) {
        return poolAuditorsMapping[id];
    }

    function getCallerAuditorByAssetId(uint256 assetId) private view returns (Auditor storage) {
        uint256 typeId = getAssetByAssetId(assetId).typeId();
        return getCallerAuditorByTypeId(typeId);

    }

    function getCallerAuditorByTypeId(uint256 typeId) private view returns (Auditor storage) {
        uint256 poolId = auditorPools[typeId].id;
        return poolAuditorsMapping[poolId][
            poolAuditorReference[poolId][msg.sender]
        ];
    }

    function getAssetByAssetId(uint256 assetId) private view returns (IAssetHolder) {
        return IAssetHolder(IAssetListHolder(assetListHolder).getAssetById(assetId).assetHolder);
    }

}
