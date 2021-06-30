// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IAssetListHolder.sol";
import "./AssetHolder.sol";
import "./shared/Structs.sol";

contract AssetListHolder is Ownable, IAssetListHolder {

    address public apxCoordinator;
    AssetDescriptor[] public assetsList;

    event AssetHolderCreated(address indexed holderAddress, address indexed tokenizedAssetAddress);

    modifier onlyApxCoordinator() {
        require(
            msg.sender == apxCoordinator,
            "Only Coordinator Contract is allowed to execute call."
        );
        _;
    }

    function setCoordinator(address coordinator) external onlyOwner {
        apxCoordinator = coordinator;
    }

    function addAsset(
        address tokenizedAsset,
        address listedBy,
        uint256 assetType,
        string memory name,
        string memory ticker,
        string memory info,
        string memory listingInfo
    ) external override onlyApxCoordinator returns (uint256) {
        uint256 assetId = assetsList.length;
        AssetHolder assetHolder = new AssetHolder(
            msg.sender,
            tokenizedAsset,
            listedBy,
            assetId,
            assetType,
            name,
            ticker,
            info,
            listingInfo
        );
        assetsList.push(AssetDescriptor(
            address(assetHolder),
            tokenizedAsset,
            assetId,
            assetType,
            name,
            ticker
        ));
        emit AssetHolderCreated(address(assetHolder), tokenizedAsset);
        return assetId;
    }

    function getAssets() external view override returns (AssetDescriptor[] memory) {
        return assetsList;
    }

    function getAssetById(uint256 id) external view override returns (AssetDescriptor memory) {
        return assetsList[id];
    }

}
