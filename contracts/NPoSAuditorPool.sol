//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./interfaces/IAuditorPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NPoSAuditorPool is IAuditorPool {

    mapping(uint256 => address[]) _councils;
    address[] _members;
    address[] _pendingMembers;

    constructor(IERC20 stakingToken, uint256 maxMembers) {

    }

    function applyForMembership() public returns(uint256) {
        _pendingMembers.push(msg.sender);
    }

    function nominate(address member) public {

    }

    function requestCouncil() override external returns (uint256) {

    }

    function isCouncilReady(uint256 requestID) override external view returns (bool) {

    }

    function getCouncil(uint256 requestID) override external view returns (address[] memory) {

    }


}
