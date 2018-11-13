pragma solidity ^0.4.24;

import "./PUBLCEntity.sol";
import "./Pausable.sol";
import "./Proxied.sol";
import "../ERC20/IERC20.sol";
import "../ERC20/IERC20Extended.sol";


contract PUBLCAccount is PUBLCEntity, Pausable, Proxied {

    /**
     * Constructor for PUBLC contract
     * @param proxy address The address PUBLC contract which performs the actions on this contract
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
        return IERC20Extended(tokenAddress).increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address tokenAddress, address spender, uint256 subtractedValue) public onlyProxyOrOwner whenNotPaused returns (bool) {
        return IERC20Extended(tokenAddress).decreaseAllowance(spender, subtractedValue);
    }
}