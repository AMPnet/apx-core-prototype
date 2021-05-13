//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IAuditorPool {

    function requestCouncil(uint256) external returns (uint256);

}
