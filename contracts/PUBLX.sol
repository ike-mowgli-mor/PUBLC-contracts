pragma solidity ^0.4.24;

import "./ERC20/ERC20Pausable.sol";
import "./types/PUBLCEntity.sol";

/**
 * @title PUBLX
 *
 * The contract of PUBLC platform's token
 */
contract PUBLX is ERC20Pausable {
    string public constant name = 'PUBLX';
    string public constant symbol = 'PUBLX';
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 100e9 * 10 ** uint256(decimals);

     /**
      * Constructor for PUBLX token
      * @param reserveAddress The address of the reserve account which receives the initial supply of tokens minted by the token contract.
      */
    constructor(address reserveAddress) public {
        PUBLCEntity(reserveAddress).validate("Reserve", "1.0.0");
        _mint(reserveAddress, INITIAL_SUPPLY);
    }
}