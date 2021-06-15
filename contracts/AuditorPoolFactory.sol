// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NPoSAuditorPool.sol";
import "./interfaces/IAuditorPoolFactory.sol";

contract AuditorPoolFactory is IAuditorPoolFactory {

    event AuditorPoolCreated(address auditorPool);

    function create(       
        address stakingToken,
        uint256 minPersonalStake,
        uint256 maxNumberOfAuditors
    ) external override returns (address) {
        address auditorPool = address(new NPoSAuditorPool(
            stakingToken,
            minPersonalStake,
            maxNumberOfAuditors
        ));
        emit AuditorPoolCreated(auditorPool);
        return auditorPool;
    }
    
}
