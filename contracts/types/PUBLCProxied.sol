pragma solidity ^0.4.24;

import "./PUBLCOwnable.sol";

/**
 * @title PUBLCProxied
 * @dev The proxy contract has a proxy address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract PUBLCProxied is PUBLCOwnable {
    address private _proxy;

    event proxyTransferred(
        address indexed previousProxy,
        address indexed newProxy
    );

    /**
     * @dev The proxy constructor sets the original `proxy` of the contract to the sender
     * account.
     */
    constructor() internal {
        _proxy = msg.sender;
        emit proxyTransferred(address(0), _proxy);
    }

    /**
     * @return the address of the proxy.
     */
    function proxy() public view returns(address) {
        return _proxy;
    }

    /**
     * @dev Throws if called by any account other than the proxy or owner.
     */
    modifier onlyProxyOrOwner() {
        require(isProxy() || isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the proxy of the contract.
     */
    function isProxy() public view returns(bool) {
        return msg.sender == _proxy;
    }

    /**
     * @dev Allows the current proxy to transfer control of the contract to a newProxy.
     * @param newProxy The address to transfer proxy to.
     */
    function transferProxy(address newProxy) public onlyProxyOrOwner {
        _transferProxy(newProxy);
    }

    /**
     * @dev Transfers control of the contract to a newProxy.
     * @param newProxy The address to transfer proxy to.
     */
    function _transferProxy(address newProxy) internal {
        require(newProxy != address(0));
        emit proxyTransferred(_proxy, newProxy);
        _proxy = newProxy;
    }
}