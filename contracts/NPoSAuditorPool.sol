//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./interfaces/IAuditorPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NPoSAuditorPool is IAuditorPool {

    mapping(uint256 => address[]) _councils;

    mapping (address=>bool) _members;
    uint256[] _memberNominations;

    mapping (address=>uint256) _nominations;
    mapping (address=>bool) _pendingMembers;

    IERC20 _stakingToken;
    uint256 _maxMembers;
    uint256 _minRequiredStake;

    uint256 _totalNominated;
    uint256 _minNomination;

    constructor(IERC20 stakingToken, uint256 maxMembers, uint256 minNomination) {
        _stakingToken = stakingToken;
        _maxMembers = maxMembers;
        _minNomination = minNomination;
    }

    function joinPool(uint256 nominationAmount) public {
        require(_members[msg.sender] != true);
        require(nominationAmount > _minNomination);

        _nominations[msg.sender] += nominationAmount;
        _pendingMembers[msg.sender] = true;
    }

    function nominate(address member, uint256 amount) public {

        require(
            _members[member] || 
            _pendingMembers[member]
        );

        if(_pendingMembers[member]) {
            _members[member] = true;
            _pendingMembers[member] = false;
        }

        _stakingToken.transferFrom(msg.sender, address(this), amount);
        _nominations[member] += amount;
        _totalNominated += amount;

    }

    function requestCouncil() override external returns (uint256) {

    }

    function isCouncilReady(uint256 requestID) override external view returns (bool) {

    }

    function getCouncil(uint256 requestID) override external view returns (address[] memory) {

    }


}
