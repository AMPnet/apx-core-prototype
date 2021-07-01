// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAPXCoordinator {
    function calcualteTransferFee(uint256 transferAmount) external view returns (uint256);
    function protocolFeeBeneficiary() external view returns (address);
}