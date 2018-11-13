pragma solidity ^0.4.24;

import "./types/PUBLCAccount.sol";
import "./types/PUBLCEntity.sol";

/**
 * @title Escrow
 *
 * A contract account managed by PUBLC, which holds token funds owned by users, awaiting withdrawal.
 */
contract Escrow is PUBLCAccount {
    /**
     * Constructor for Escrow contract
     * @param proxy The address of PUBLC contract, which has permission to perform actions on this contract
     */
    constructor(address proxy) public PUBLCEntity("Escrow", "1.0.0") PUBLCAccount(proxy) {}
}
