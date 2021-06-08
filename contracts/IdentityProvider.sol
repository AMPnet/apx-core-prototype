// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IdentityProvider {

    struct Identity {
        address wallet;
        string ipfsInfo;
        bool whitelisted;
    }

    mapping(address => Identity) public id; 
    
}