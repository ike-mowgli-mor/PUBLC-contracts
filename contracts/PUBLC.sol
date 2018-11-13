pragma solidity ^0.4.24;

import "./Reserve.sol";
import "./Escrow.sol";
import "./math/SafeMath.sol";
import "./types/Pausable.sol";
import "./types/Proxied.sol";
import "./types/Ownable.sol";
import "./types/PUBLCEntity.sol";
import "./types/PUBLCAccount.sol";
import "./ERC20/IERC20.sol";

contract PUBLC is PUBLCEntity, Pausable, Proxied {
    using SafeMath for uint256;

    struct PublcTransaction {
        string id;
        address from;
        address to;
        uint256 value;
    }
    address private _tokenAddress;
    address private _reserveAddress;
    address private _escrowAddress;
    mapping (string => PublcTransaction) private _publcTransactions;

    /**
     * Constructor for PUBLC contract
     * @param proxy address The address of PUBLC platform's account which performs the transactions
     */
    constructor(address proxy) public PUBLCEntity("PUBLC", "1.0.0") {
        transferProxy(proxy);
    }

     // events
    event PublcTransactionEvent(string publxId, address from, address to, uint256 value);
    event SetTokenAddress(address tokenAddress);
    event SetNewPublcAccount(address currentAddress, address newAddress, string name, string version);
    event Retire(address publcAddress);

     /**
      * Sets the token address
      * @param tokenAddress address The new token address to use
      */
    function setTokenAddress(address tokenAddress) public onlyOwner whenNotPaused {
        _tokenAddress = tokenAddress;
         emit SetTokenAddress(_tokenAddress);
    }

    /**
     * Sets the escrow address
     * @param escrowAddress address The new escrow address to use
     */
    function setEscrow(address newEscrowAddress, string version) public onlyOwner whenNotPaused {
        setNewPublcAccount(_escrowAddress, newEscrowAddress, "Escrow", version);
        _escrowAddress = newEscrowAddress;
    }

    /**
     * Sets the bank address
     * @param bankAddress address The new bank address to use
     */
    function setReserve(address newReserveAddress, string version) public onlyOwner whenNotPaused {
        setNewPublcAccount(_reserveAddress, newReserveAddress, "Reserve", version);
        _reserveAddress = newReserveAddress;
    }

    /**
     * Transfers the current PUBLCAccount contract's balance to the PUBLCAccount new contract and pauses the current one
     * @param currentAddress address The current PUBLCAccount's address
     * @param newAddress address The new PUBLCAccount's address
     * @param name string The new PUBLCAccount's name to validate
     * @param version string address The new PUBLCAccount's version to validate
     */
    function setNewPublcAccount(address currentAddress, address newAddress, string name, string version) private onlyOwner whenNotPaused {
        PUBLCEntity(newAddress).validate(name, version);
        if (currentAddress != address(0)) {
            uint256 balance = IERC20(_tokenAddress).balanceOf(currentAddress);
            PUBLCAccount currentPublcAccount = PUBLCAccount(currentAddress);
            currentPublcAccount.transfer(_tokenAddress, newAddress, balance);
            currentPublcAccount.pause();
        }
        emit SetNewPublcAccount(currentAddress, newAddress, name, version);
    }

    /**
     * Performs a transaction that came from PUBLC platform
     * @param publcTxId string The transaction id in PUBLC's platform
     * @param from address The sender contract's address
     * @param to address The reciever's address
     * @param value uint256 The value of the tokens to be sent
     */
    function doPublcTransaction(string publcTxId, address from, address to, uint256 value) public onlyProxyOrOwner whenNotPaused {
        require(from == _reserveAddress || from == _escrowAddress);
        require(value > 0);
        require(_publcTransactions[publcTxId].value == 0);
        PUBLCAccount(from).transfer(_tokenAddress, to, value);
        _publcTransactions[publcTxId] = PublcTransaction(publcTxId, from, to, value);
        emit PublcTransactionEvent(publcTxId, from, to, value);
    }

    /**
     * Stops the current PUBLC contract and switches it to new PUBLC contract
     * @param newPublc address The new PUBLC's address
     * @param version address The new PUBLC's version to validate
     */
    function setNewPublc(address newPublc, string version) public onlyOwner whenNotPaused {
        PUBLCEntity(newPublc).validate("PUBLC", version);
        PUBLCAccount(_reserveAddress).transferProxy(newPublc);
        PUBLCAccount(_escrowAddress).transferProxy(newPublc);
        pause();
    }

    function tokenAddress() public view returns (address) {
        return _tokenAddress;
    }

    function escrowAddress() public view returns (address) {
        return _escrowAddress;
    }

    function reserveAddress() public view returns (address) {
        return _reserveAddress;
    }

    function publcTx(string publcTxId) public view returns (address, address, uint256) {
        return (_publcTransactions[publcTxId].from, _publcTransactions[publcTxId].to, _publcTransactions[publcTxId].value);
    }

    function circulatingSupply() public view returns(uint256) {
        IERC20 token = IERC20(_tokenAddress);
        return token.totalSupply().sub(token.balanceOf(_reserveAddress));
    }
}