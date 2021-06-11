// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAssetListHolder {
    function addAsset(
        string memory name,
        uint256 id,
        uint256 procedure,
        address tokenizedAsset, 
        string memory additionalInfo
    ) external;
}
