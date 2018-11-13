pragma solidity ^0.4.24;

import "./Ownable.sol";

/**
 * @title Proxied
 * @dev The proxy contract has an proxy address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Proxied is Ownable {
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
     * @dev Throws if called by any account other than the proxy.
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
     * @dev Allows the current proxy to relinquish control of the contract.
     * @notice Renouncing to proxy will leave the contract without an proxy.
     * It will not be possible to call the functions with the `onlyproxy`
     * modifier anymore.
     */
    function renounceProxy() public onlyProxyOrOwner {
        emit proxyTransferred(_proxy, address(0));
        _proxy = address(0);
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