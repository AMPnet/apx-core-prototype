// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAuditorPoolFactory {
    function create(
        address stakingToken,
        uint256 minPersonalStake,
        uint256 minStakeToQualify,
        uint256 maxNumberOfAuditors
    ) external returns (address);
}
