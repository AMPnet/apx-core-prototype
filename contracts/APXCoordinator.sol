//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract APXCoordinator is Ownable {

    struct AssetCategory {
        uint256 categoryId;
        string categoryDescriptionIPFS;
        bool active;
    }

    mapping(uint256 => AssetCategory) public categories;
    address public arbitersCommittee;

    constructor(address _arbitersCommittee) {
        arbitersCommittee = _arbitersCommittee;
    }

    function addAssetCategory(uint256 categoryId, string memory categoryDescriptionIPFS) external onlyOwner {
        require(
            categoryId > 0,
            "New Asset category must have a unique id > 0");
        require(
            categories[categoryId].categoryId == 0,
            "Asset category with given id already exits"
        );

        categories[categoryId] = AssetCategory(categoryId, categoryDescriptionIPFS, false);

    }

    function suspendAssetCategory(uint256 categoryId) external onlyOwner {
        categories[categoryId].active = false;
    }

}
