//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract AuditingProcedures is Ownable {
  
    mapping (uint256 => string) public procedures;

    function addProcedure(uint256 procedureID, string memory procedureIPFSHash) public onlyOwner {
        require(bytes(procedures[procedureID]).length == 0, "Procedure already exists, use update procedure call");
        procedures[procedureID] = procedureIPFSHash;
    }

    function updateProcedure(uint256 procedureID, string memory procedureIPFSHash) public onlyOwner {
        require(bytes(procedures[procedureID]).length > 0, "Procedure doesn't exist");
        procedures[procedureID] = procedureIPFSHash;
    }

    function removeProcedure(uint256 procedureID) public onlyOwner {
        procedures[procedureID] = "";
    }
  
}
