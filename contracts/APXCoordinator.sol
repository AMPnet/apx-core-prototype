//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract APXCoordinator is Ownable {

    address public arbitersCommittee;
    address public nposAuditorPool;
    address public auditingProcedures;
    address public assetList;

    constructor(
        address _arbitersCommittee,
        address _nposAuditorPool,
        address _auditingProcedures,
        address _assetList
    ) {
        arbitersCommittee = _arbitersCommittee;
        nposAuditorPool = _nposAuditorPool;
        auditingProcedures = _auditingProcedures;
        assetList = _assetList;
    }

}
