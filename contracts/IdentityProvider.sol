// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract IdentityProvider is Ownable {

    struct Identity {
        address wallet;
        string ipfsInfo;
        bool whitelisted;
    }

    mapping(address => Identity) public id;

    event IdentityUpdated(address indexed wallet, bool whitelisted);

    function update(address wallet, string memory ipfsInfo, bool whitelisted) external onlyOwner {
        id[wallet].whitelisted = whitelisted;
        id[wallet].ipfsInfo = ipfsInfo;
        emit IdentityUpdated(wallet, whitelisted);
    }
    
}
