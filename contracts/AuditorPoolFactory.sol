// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NPoSAuditorPool.sol";
import "./interfaces/IAuditorPoolFactory.sol";

contract AuditorPoolFactory {

    event AuditorPoolCreated(address auditorPool);

    function create(       
        address stakingToken,
        uint256 minPersonalStake,
        uint256 minStakeToQualify,
        uint256 maxNumberOfAuditors
    ) external returns (address) {
        address auditorPool = address(new NPoSAuditorPool(
            stakingToken,
            minPersonalStake,
            minStakeToQualify,
            maxNumberOfAuditors
        ));
        emit AuditorPoolCreated(auditorPool);
        return auditorPool;
    }
    
}
