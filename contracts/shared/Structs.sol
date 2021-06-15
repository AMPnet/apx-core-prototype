// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct AssetDescriptor {
    string name;
    uint256 id;
    uint256 auditorPoolId;
    uint256 procedureId;
}
    
struct AuditResult {
    bool assetVerified;
    string additionalInfo;
    uint256 timestamp;
}
