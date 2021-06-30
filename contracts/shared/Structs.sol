// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct AssetType {
    uint256 id;
    string name;
    string info;
}

struct AssetDescriptor {
    address assetHolder;
    address tokenizedAsset;
    uint256 id;
    uint256 typeId;
    string name;
    string ticker;
}

struct AuditorPool {
    uint256 id;
    string name;
    string info;
    bool active;
    uint256 activeMembers;
    Auditor[] auditorsList;
}

struct Auditor {
    address auditor;
    uint256 totalAuditsPerformed;
    uint256 totalAuditsCharged;
    uint256 totalListingsPerformed;
    uint256 totalListingsCharged;
    uint256 totalEscalationsInitiated;
    uint256 totalEscalationsHandled;
    bool registered;
    bool active;
    string info;
}
    
struct AuditResult {
    bool assetVerified;
    string additionalInfo;
    uint256 timestamp;
}
