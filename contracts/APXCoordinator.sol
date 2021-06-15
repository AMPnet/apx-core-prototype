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

    // STATE VARS
    address[] public auditorPools;
    address public auditingProcedures;
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
        address _auditingProcedures,
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
        auditingProcedures = _auditingProcedures;
        assetListHolder = _assetListHolder;
        auditGapDuration = _auditGapDuration;
        auditDuration = _auditDuration;
        councilSize = _councilSize;
        minPersonalStake = _minPersonalStake;
        minStakeToQualify = _minStakeToQualify;
        maxNumberOfAuditors = _maxNumberOfAuditors;
        stakingToken = _stakingToken;
    }

    function createNewAuditorPool() external onlyOwner returns (address) {
        address pool = address(IAuditorPoolFactory(auditorPoolFactory).create(
            stakingToken,
            minPersonalStake,
            minStakeToQualify,
            maxNumberOfAuditors
        ));
        auditorPools.push(pool);
        return address(pool);
    }

    function listAsset(
        uint256 assetId,
        uint256 procedureId,
        uint256 auditorPoolId,
        address tokenizedAsset,
        string memory name,
        string memory additionalInfo
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
