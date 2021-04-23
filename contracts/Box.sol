//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Box is Ownable {

    uint256 _amount;

    constructor (uint256 amount) {
        _amount = amount;
    }

    function changeAmount(uint256 newAmount) public onlyOwner{

    }

}