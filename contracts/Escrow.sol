pragma solidity ^0.4.24;

import "./types/PUBLCAccount.sol";
import "./types/PUBLCEntity.sol";

contract Escrow is PUBLCAccount {
    constructor(address proxy) public PUBLCEntity("Escrow", "1.0.0") PUBLCAccount(proxy) {}
}
