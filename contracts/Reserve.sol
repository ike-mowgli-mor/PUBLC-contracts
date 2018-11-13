pragma solidity ^0.4.24;

import "./types/PUBLCEntity.sol";
import "./types/PUBLCAccount.sol";

/**
 * @title Reserve
 *
 * A contract account managed by PUBLC, which holds token funds not yet released to circulation.
 */
contract Reserve is PUBLCAccount {
    /**
     * Constructor for Escrow contract
     * @param proxy The address of PUBLC contract, which has permission to perform actions on this contract
     */
    constructor(address proxy) public PUBLCEntity("Reserve", "1.0.0") PUBLCAccount(proxy) {}
}
