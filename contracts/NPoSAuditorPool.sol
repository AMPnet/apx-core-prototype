//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./interfaces/IAuditorPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract NPoSAuditorPool is IAuditorPool, Ownable {

    struct Council {
        address[] members;
        uint256 timeCreated;
        bool ready;
    }

    struct MemberInfo {
        uint256 totalNominated;
        uint256 selfStaked;
        bool hasApplied;
        bool isQualified;
    }

    struct Nomination {
        address nominee;
        uint256 amount;
    }

    IERC20 _stakingToken;
    Council[] _councils;
    mapping(address => MemberInfo) _members;
    address[] _qualifiedMembers;

    uint256 _minimumPersonalStake;
    uint256 _maxNumberOfAuditors;
    uint256 _minStakeToQualify;

    mapping(address => Nomination[]) _nominations;

    constructor(
        IERC20 stakingToken,
        uint256 minimumPersonalStake,
        uint256 maxNumberOfAuditors
    ) Ownable() {
        _stakingToken = stakingToken;
        _minimumPersonalStake = minimumPersonalStake;
        _maxNumberOfAuditors = maxNumberOfAuditors;
    }

    function applyForMembership(uint256 stakeAmount) public {
        require(!_members[msg.sender].hasApplied);
        require(stakeAmount > _minimumPersonalStake);

        _stakingToken.transferFrom(msg.sender, address(this), stakeAmount);

        _members[msg.sender] = MemberInfo(
            stakeAmount,
            stakeAmount,
            true,
            false
        );
    }

    function nominate(uint256 amount, address nominee) public {

        require(
            _members[nominee].hasApplied,
            "The address you are trying to nominate hasn't applied to become an auditor"
        );

        require(
            _nominations[msg.sender].length < 10,
            "You cannot have more than 10 active nominations"
        );

        _stakingToken.transferFrom(
            msg.sender, 
            address(this), 
            amount
        );

        _members[nominee].totalNominated += amount;

        // Check if the nominee has more stake nominated than the lowest member of the qualified members;
        uint256 smallestStake = _stakingToken.totalSupply();
        address smallestStakeHolder = address(0x0);
        for(uint i = 0; i < _maxNumberOfAuditors; i++) {

            address currentMemberAddress = _qualifiedMembers[i];
            uint currentMemberNomination = _members[currentMemberAddress].totalNominated;

            if(currentMemberNomination < smallestStake) {
                smallestStake = currentMemberNomination;
                smallestStakeHolder = currentMemberAddress;
            }
        }

        // If nominee has more stake than lowest member, replace lowest member with nominee
        if(_members[nominee].totalNominated > smallestStake) {
            for(uint i = 0; i < (_maxNumberOfAuditors - 1); i++) {
                if(_qualifiedMembers[i] == smallestStakeHolder) {
                    _qualifiedMembers[i] = nominee;
                }
            }
        }

        _nominations[msg.sender].push(Nomination(
            nominee,
            amount
        ));

    }

    function requestCouncil(uint256 size) external override returns (uint256) {

        require(
            size < _qualifiedMembers.length,
            "Size of the council cannot be greater than maximum number of validators"
        );

        // Array for Cumulative Distribution Function
        uint256[] memory cdf = new uint256[](_qualifiedMembers.length);

        // Filling CDF
        cdf[0] = _members[_qualifiedMembers[0]].totalNominated;
        for(uint i = 1; i < _qualifiedMembers.length; i++) {
            cdf[i] = cdf[i - 1] + _members[_qualifiedMembers[i]].totalNominated;
        }

        // Random number - to get from Chainlink
        uint256 randomNumber = 12345678;
        address[] memory selected = new address[](size);

        for(uint i = 0; i < size; i++) {
            for(uint j = 0; j < cdf.length; j++) {
                if(cdf[j] > randomNumber) {
                    selected[i] = _qualifiedMembers[j];
                    break;
                } 
            }
            randomNumber = 23456;
        }

        _councils.push(Council(
            selected,
            block.timestamp,
            false
        ));

        return (_councils.length - 1);
        
    }

}
