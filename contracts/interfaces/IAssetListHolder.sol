// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAssetListHolder {
    function addAsset(
        string memory name,
        uint256 assetId,
        uint256 procedureId,
        uint256 auditorPoolId,
        address tokenizedAsset, 
        string memory additionalInfo
    ) external;
    function assets(uint256 index) external returns (address);
}
