// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";

contract CustomContractFactory is Ownable {
    
    mapping (bytes => bool) private _whitelist;
    
    event CreationError(string);

    function createContract(bytes memory bytecode) private returns (address) {
        address addr;
        assembly {
            addr := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        return addr;
    }
    
    function addToWhitelist(bytes memory bytecode) public {
        address addr  = createContract(bytecode);
        require(addr == msg.sender, "only contract owner is allowed to add to whitelist");
        require(!_whitelist[bytecode], "Contract already added to whitelist");
        _whitelist[bytecode] = true;
    }
    
    function removeFromWhitelist(bytes memory bytecode) public {
        address addr  = createContract(bytecode);
        require(addr == msg.sender, "only contract owner is allowed to remove from whitelist");
        delete _whitelist[bytecode];
    }
    
    function isWhitelisted(bytes memory bytecode) private view returns (bool) {
        return _whitelist[bytecode];
    }
    
    function deploy(bytes memory bytecode) public returns (address) {
        if (!isWhitelisted(bytecode)) {
            emit CreationError("Failed to create contract: not on whitelist");
        }
        address addr = createContract(bytecode);

        if (addr == address(0)) {
            emit CreationError("Failed to create contract");
        }
        return addr;
    }
}