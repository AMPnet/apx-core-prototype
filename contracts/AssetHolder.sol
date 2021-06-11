//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract AssetHolder {
  
    struct AssetDescriptor {
        string name;
        uint256 id;
        uint256 procedure;
    }
    
    struct AuditResult {
        bool assetVerified;
        string additionalInfo;
        uint256 timestamp;
    }

    address public auditor;
    address public tokenizedAsset;
    AssetDescriptor public descriptor;
    AuditResult public latestAudit;

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
        uint256 _id,
        uint256 _procedure,
        address _tokenizedAsset
    ) {
        tokenizedAsset = _tokenizedAsset;
        descriptor = AssetDescriptor(_name, _id, _procedure);
    }

    function performAudit(bool assetVerified, string memory additionalInfo) external onlyAuditor {
        latestAudit = AuditResult(assetVerified, additionalInfo, block.timestamp);
        emit AuditPerformed(assetVerified);
    }
  
}
