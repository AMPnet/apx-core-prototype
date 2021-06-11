//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IAssetListHolder.sol";

contract APXCoordinator is Ownable {

    address public arbitersCommittee;
    address public nposAuditorPool;
    address public auditingProcedures;
    address public assetListHolder;
    address public auditor;

    event AssetListed(address indexed tokenizedAsset);

    constructor(
        address _arbitersCommittee,
        address _nposAuditorPool,
        address _auditingProcedures,
        address _assetListHolder,
        address _auditor
    ) {
        arbitersCommittee = _arbitersCommittee;
        nposAuditorPool = _nposAuditorPool;
        auditingProcedures = _auditingProcedures;
        assetListHolder = _assetListHolder;
        auditor = _auditor;
    }

    modifier onlyArbitersCommittee() {
        require(
            msg.sender == arbitersCommittee,
            "Only Arbiters Committee can execute this call."
        );
        _;
    }

    function listAsset(
        string memory name,
        uint256 id,
        uint256 procedure,
        address tokenizedAsset, 
        string memory additionalInfo
    ) external onlyArbitersCommittee {
        IAssetListHolder(assetListHolder).addAsset(name, id, procedure, tokenizedAsset, additionalInfo);
        emit AssetListed(tokenizedAsset);
    }

}
