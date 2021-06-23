//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./interfaces/IAssetHolder.sol";
import { AuditResult } from "./shared/Structs.sol";

contract AssetHolder is IAssetHolder {
  
    address public apxCoordinator;

    uint256 public override id;
    uint256 public override typeId;
    string public name;
    string public info;
    address public tokenizedAsset;
    address public listedBy;
    string public listingInfo;
    AuditResult public latestAudit;

    modifier onlyApxCoordinator() {
        require(
            msg.sender == apxCoordinator,
            "Only Coordinator Contract can execute this call."
        );
        _;
    }

    event AuditPerformed(bool assetVerified);

    constructor(
        address _apxCoordinator,
        address _tokenizedAsset,
        address _listedBy,
        uint256 _id,
        uint256 _typeId,
        string memory _name,
        string memory _info,
        string memory _listingInfo
    ) {
        apxCoordinator = _apxCoordinator;
        id = _id;
        typeId = _typeId;
        name = _name;
        info = _info;
        tokenizedAsset = _tokenizedAsset;
        listedBy = _listedBy;
        listingInfo = _listingInfo;
    }

    function performAudit(bool assetVerified, string memory additionalInfo) external override onlyApxCoordinator {
        latestAudit = AuditResult(assetVerified, additionalInfo, block.timestamp);
        emit AuditPerformed(assetVerified);
    }

    function getLatestAudit() external override view returns (AuditResult memory) {
        return latestAudit;    
    }

}
