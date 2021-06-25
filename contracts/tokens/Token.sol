// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Token is ERC20 {
    using SafeERC20 for IERC20;

    mapping(address => mapping(address => uint256)) fundTransfers; 

    constructor(uint256 initialSupply) ERC20("Token", "TKN") {
        _mint(msg.sender, initialSupply);
    }

    function fundWallet(IERC20 token, uint256 amount, address spender) external returns (bool) {
        token.safeTransferFrom(msg.sender, address(this), amount);
        token.approve(spender, amount);
        fundTransfers[msg.sender][address(token)] += amount;
        return true;
    }

    function withdrawFunds(address token, uint256 amount) external returns (bool) {
        require(
            fundTransfers[msg.sender][token] >= amount,
            "Withdraw amount too high."
        );
        fundTransfers[msg.sender][token] -= amount;
        IERC20(token).safeTransferFrom(address(this), msg.sender, amount);
        return true;
    }

}
