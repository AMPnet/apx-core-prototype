// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract ArbitersCommittee is Ownable {

    struct Arbiter {
        address arbiter;
        uint256 actionsTaken;
        uint256 actionsCharged;
        bool active;
    }

    struct Application {
        address arbiter;
        uint256 categoryId;
        bool active;
    }

    mapping(address => Application) applications;
    mapping(address => Arbiter) arbitersByAddress;
    mapping(uint256 => Arbiter) arbitersByCategoryId;

    event ArbiterApplied(address indexed arbiter, uint256 categoryId);
    event ArbiterCancelledApplication(address indexed arbiter, uint256 categoryId);
    event ArbiterApproved(address indexed arbiter, uint256 categoryId);

    function applyForArbiter(uint256 categoryId) external {
        applications[msg.sender] = Application(
            msg.sender,
            categoryId,
            true
        );
        emit ArbiterApplied(msg.sender, categoryId);
    }

    function cancelApplication() public {
        applications[msg.sender].active = false;
        emit ArbiterCancelledApplication(msg.sender, applications[msg.sender].categoryId);
    }

    function approveArbiter(address arbiterAddress) external onlyOwner {
        Application storage application = applications[arbiterAddress];
        require(application.active, "Arbiter has not applied.");
        require(
            !arbitersByAddress[application.arbiter].active,
            "Arbiter is already active."
        );
        require(
            !arbitersByCategoryId[application.categoryId].active,
            "There is an arbiter already assigned to this asset category."
        );
        application.active = false;
        Arbiter memory arbiter = Arbiter(arbiterAddress, 0, 0, true);
        arbitersByAddress[application.arbiter] = arbiter;
        arbitersByCategoryId[application.categoryId] = arbiter;
        emit ArbiterApproved(application.arbiter, application.categoryId);
    }

}
