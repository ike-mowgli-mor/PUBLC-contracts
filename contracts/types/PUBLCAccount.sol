pragma solidity ^0.4.24;

import "../ERC20/IERC20.sol";
import "../ERC20/IERC20Extension.sol";
import "./Pausable.sol";
import "./Proxied.sol";
import "./PUBLCEntity.sol";

/**
 * @title PUBLCAccount
 *
 * A contract account managed by PUBLC, which holds token funds and performs all ERC20 functionalities.
 */
contract PUBLCAccount is PUBLCEntity, Pausable, Proxied {

    /**
     * Constructor for PUBLCAccount contract
     * @param proxy The address of PUBLC contract, which has permission to perform actions on behalf of this contract
     */
    constructor(address proxy) public {
        transferProxy(proxy);
        addPauser(proxy);
    }

    function transfer(address tokenAddress, address to, uint256 value) public onlyProxyOrOwner whenNotPaused returns(bool) {
        return IERC20(tokenAddress).transfer(to, value);
    }

    function approve(address tokenAddress, address spender, uint256 value) public onlyProxyOrOwner whenNotPaused returns (bool) {
        return IERC20(tokenAddress).approve(spender, value);
    }

    function transferFrom(address tokenAddress, address from, address to, uint256 value) public onlyProxyOrOwner whenNotPaused returns (bool) {
        return IERC20(tokenAddress).transferFrom(from, to, value);
    }

    function increaseAllowance(address tokenAddress, address spender, uint256 addedValue) public onlyProxyOrOwner whenNotPaused returns (bool) {
        return IERC20Extension(tokenAddress).increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address tokenAddress, address spender, uint256 subtractedValue) public onlyProxyOrOwner whenNotPaused returns (bool) {
        return IERC20Extension(tokenAddress).decreaseAllowance(spender, subtractedValue);
    }
}