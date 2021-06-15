// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { AuditResult, AssetDescriptor } from "../shared/Structs.sol";

interface IAssetHolder {
    function getLatestAudit() external view returns (AuditResult memory);
    function getDescriptor() external view returns (AssetDescriptor memory);
}
