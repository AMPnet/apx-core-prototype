// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IAssetListHolder.sol";
import "./AssetHolder.sol";

contract AssetListHolder is Ownable, IAssetListHolder {

    address public apxCoordinator;
    address[] public override assetsList;

    constructor(address _apxCoordinator) {
        apxCoordinator = _apxCoordinator;
    }

    event AssetHolderCreated(address indexed holderAddress, address indexed tokenizedAssetAddress);

    modifier onlyApxCoordinator() {
        require(
            msg.sender == apxCoordinator,
            "Only APX Coordinator is allowed to execute call."
        );
        _;
    }

    /*
        address tokenizedAsset,
        string memory name,
        string memory info,
        string memory listingInfo
    */

    function addAsset(
        address tokenizedAsset,
        string memory name,
        string memory info,
        string memory listingInfo
    ) external override onlyApxCoordinator {
        AssetHolder assetHolder = new AssetHolder(
            name,
            assetId,
            auditorPoolId,
            procedureId,
            tokenizedAsset
        );
        assets.push(address(assetHolder));
        emit AssetHolderCreated(address(assetHolder), tokenizedAsset);
    }

}
