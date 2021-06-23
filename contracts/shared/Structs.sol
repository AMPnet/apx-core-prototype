// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct AssetType {
    uint256 id;
    string name;
    string info;
}

struct AuditorPool {
    uint256 id;
    string name;
    string info;
    bool active;
    uint256 activeMembers;
    Auditor[] auditorsList;
    mapping(address => Auditor) auditors;
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
