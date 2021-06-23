// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAssetListHolder {
    function addAsset(
        address tokenizedAsset,
        address listedBy,
        uint256 assetType,
        string memory name,
        string memory info,
        string memory listingInfo
    ) external returns (uint256);
    function assets(uint256 index) external view returns (address);
    function getAssets() external returns (address[] memory);
}
