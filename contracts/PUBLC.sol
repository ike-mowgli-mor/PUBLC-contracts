pragma solidity ^0.4.24;

import "./math/SafeMath.sol";
import "./ERC20/IERC20.sol";
import "./types/PUBLCOwnable.sol";
import "./types/PUBLCProxied.sol";
import "./types/PUBLCPausable.sol";
import "./Reserve.sol";
import "./Escrow.sol";
import "./types/PUBLCEntity.sol";
import "./types/PUBLCAccount.sol";

/**
 * @title PUBLC
 *
 * Manages the Reserve and Escrow accounts and syncs PUBLC platform's ledger to Ethereum.
 */
contract PUBLC is PUBLCEntity, PUBLCPausable, PUBLCProxied {
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

    event PublcTransactionEvent(string publxId, address from, address to, uint256 value);
    event SetTokenAddress(address tokenAddress);
    event SetNewPublcAccount(address currentAddress, address newAddress, string name, string version);
    event SetNewPublc(address publcAddress);

    /**
     * Constructor for PUBLC contract
     * @param proxy The address of PUBLC platform's account which signs the transactions
     */
    constructor(address proxy) public PUBLCEntity("PUBLC", "1.0.0") {
        transferProxy(proxy);
    }

     /**
      * Sets the token address
      * @param tokenAddress The new token address to use
      */
    function setTokenAddress(address tokenAddress) public onlyOwner whenNotPaused {
        _tokenAddress = tokenAddress;
         emit SetTokenAddress(_tokenAddress);
    }

    /**
     * Sets the escrow address
     * @param newEscrowAddress The new escrow address to use
     */
    function setEscrow(address newEscrowAddress, string version) public onlyOwner whenNotPaused {
        setNewPublcAccount(_escrowAddress, newEscrowAddress, "Escrow", version);
        _escrowAddress = newEscrowAddress;
    }

    /**
     * Sets the reserve address
     * @param newReserveAddress The new reserve address to use
     */
    function setReserve(address newReserveAddress, string version) public onlyOwner whenNotPaused {
        setNewPublcAccount(_reserveAddress, newReserveAddress, "Reserve", version);
        _reserveAddress = newReserveAddress;
    }

    /**
     * Changes the PUBLCAccount by transferring the current PUBLCAccount's balance to the new PUBLCAccount and pauses the current one.
     * @param currentAddress The current PUBLCAccount's address
     * @param newAddress The new PUBLCAccount's address
     * @param name The new PUBLCAccount's name to validate
     * @param version The new PUBLCAccount's version to validate
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
     * Switches to new PUBLC contract by transferring the proxy of PUBLCAccounts and pausing the current PUBLC contract.
     * @param newPublc The new PUBLC's address
     * @param version The new PUBLC's version to validate
     */
    function setNewPublc(address newPublc, string version) public onlyOwner whenNotPaused {
        PUBLCEntity(newPublc).validate("PUBLC", version);
        PUBLCAccount(_reserveAddress).transferProxy(newPublc);
        PUBLCAccount(_escrowAddress).transferProxy(newPublc);
        pause();
        emit SetNewPublc(newPublc);
    }

    /**
     * Performs a transaction that syncs PUBLC platform's ledger with Ethereum.
     * @param publcTxId The transaction ID in PUBLC platform's ledger
     * @param from The sender contract's address
     * @param to The reciever's address
     * @param value The value of the tokens to be sent
     */
    function doPublcTransaction(string publcTxId, address from, address to, uint256 value) public onlyProxyOrOwner whenNotPaused {
        require(from == _reserveAddress || from == _escrowAddress);
        require(value > 0);
        require(_publcTransactions[publcTxId].value == 0);
        PUBLCAccount(from).transfer(_tokenAddress, to, value);
        _publcTransactions[publcTxId] = PublcTransaction(publcTxId, from, to, value);
        emit PublcTransactionEvent(publcTxId, from, to, value);
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

    /**
     * Returns the tokens supply which were distributed to circulation.
     */
    function circulatingSupply() public view returns(uint256) {
        IERC20 token = IERC20(_tokenAddress);
        return token.totalSupply().sub(token.balanceOf(_reserveAddress));
    }
}