// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../shared/Structs.sol";

interface IAssetListHolder {
    function addAsset(
        address tokenizedAsset,
        address listedBy,
        uint256 assetType,
        string memory name,
        string memory ticker,
        string memory info,
        string memory listingInfo
    ) external returns (uint256);
    function getAssets() external view returns (AssetDescriptor[] memory);
    function getAssetById(uint256 id) external view returns (AssetDescriptor memory);
}
