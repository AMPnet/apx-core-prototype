// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IArbitersCommittee {
    function arbiterForCategory(uint256 categoryId) external returns (address);
}