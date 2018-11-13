pragma solidity ^0.4.24;

import "./types/PUBLCEntity.sol";
import "./types/PUBLCAccount.sol";

contract Reserve is PUBLCAccount {
    constructor(address proxy) public PUBLCEntity("Reserve", "1.0.0") PUBLCAccount(proxy) {}
}
