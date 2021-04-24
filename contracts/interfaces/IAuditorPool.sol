//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IAuditorPool {

    function requestCouncil() external returns (uint256);

    function isCouncilReady(uint256) external view returns (bool);

    function getCouncil(uint256) external view returns (address[] memory);
}
