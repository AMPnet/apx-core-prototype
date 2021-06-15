//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/"
import "./interfaces/IAssetHolder.sol";
import { AssetDescriptor, AuditResult } from "./shared/Structs.sol";

contract AssetHolder is IAssetHolder {
  
    address public tokenizedAsset;
    AssetDescriptor public descriptor;
    AuditResult public latestAudit;

    bool public auditInProgress;
    uint256 public auditStartedTimestamp;

    event AuditStarted()
    event AuditPerformed(bool assetVerified);

    modifier onlyAuditor() {
        require(
            msg.sender == auditor,
            "Only Auditor Contract can execute this call."
        );
        _;
    }

    constructor(
        string memory _name,
        uint256 _assetId,
        uint256 _auditorPoolId,
        uint256 _procedureId,
        address _tokenizedAsset
    ) {
        tokenizedAsset = _tokenizedAsset;
        descriptor = AssetDescriptor(_name, _assetId, _auditorPoolId, _procedureId);
    }

    function startAudit() external  {}

    function performAudit(bool assetVerified, string memory additionalInfo) external onlyAuditor {
        latestAudit = AuditResult(assetVerified, additionalInfo, block.timestamp);
        emit AuditPerformed(assetVerified);
    }

    function getLatestAudit() external override view returns (AuditResult memory) {
        return latestAudit;    
    }

    function getDescriptor() external override view returns (AssetDescriptor memory) {
        return descriptor;
    }

}
