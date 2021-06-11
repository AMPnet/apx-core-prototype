// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IAssetListHolder.sol";
import "./AssetHolder.sol";

contract AssetListHolder is Ownable, IAssetListHolder {

    address public apxCoordinator;

    address[] public assets;

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

    function addAsset(
        string memory name,
        uint256 id,
        uint256 procedureId,
        address tokenizedAsset,
        string memory additionalInfo
    ) external override onlyApxCoordinator {
        AssetHolder assetHolder = new AssetHolder(
            name,
            id,
            procedureId,
            tokenizedAsset
        );
        assets.push(address(assetHolder));
        emit AssetHolderCreated(address(assetHolder), tokenizedAsset);
    }

}
