// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IAssetListHolder.sol";
import "./AssetHolder.sol";

contract AssetListHolder is Ownable, IAssetListHolder {

    address public apxCoordinator;
    address[] public override assets;

    event AssetHolderCreated(address indexed holderAddress, address indexed tokenizedAssetAddress);

    modifier onlyApxCoordinator() {
        require(
            msg.sender == apxCoordinator,
            "Only Coordinator Contract is allowed to execute call."
        );
        _;
    }

    function setCoordinator(address coordinator) external {
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
        uint256 assetId = assets.length;
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
        assets.push(address(assetHolder));
        emit AssetHolderCreated(address(assetHolder), tokenizedAsset);
        return assetId;
    }

    function getAssets() external view override returns (address[] memory) {
        return assets;
    }

}
