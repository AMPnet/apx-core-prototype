// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { AuditResult } from "../shared/Structs.sol";

interface IAssetHolder {
    function id() external view returns (uint256);
    function typeId() external view returns (uint256);
    function getLatestAudit() external view returns (AuditResult memory);
    function performAudit(bool assetVerified, string memory additionalInfo) external;
}
