pragma solidity ^0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

/**
 * @title PUBLCOwnable
 * @dev The PUBLCOwnable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract PUBLCOwnable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The PUBLCOwnable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   * @dev give an account access to this role
   */
  function add(Role storage role, address account) internal {
    require(account != address(0));
    require(!has(role, account));

    role.bearer[account] = true;
  }

  /**
   * @dev remove an account's access to this role
   */
  function remove(Role storage role, address account) internal {
    require(account != address(0));
    require(has(role, account));

    role.bearer[account] = false;
  }

  /**
   * @dev check if an account has this role
   * @return bool
   */
  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
    require(account != address(0));
    return role.bearer[account];
  }
}


contract PUBLCPauserRole is PUBLCOwnable {
  using Roles for Roles.Role;

  event PauserAdded(address indexed account);
  event PauserRemoved(address indexed account);

  Roles.Role private pausers;

  constructor() internal {
    _addPauser(msg.sender);
  }

  modifier onlyPauserOrOwner() {
    require(isOwner() || isPauser(msg.sender));
    _;
  }

  modifier onlyPauser() {
    require(isPauser(msg.sender));
    _;
  }

  function isPauser(address account) public view returns (bool) {
    return pausers.has(account);
  }

  function addPauser(address account) public onlyPauserOrOwner {
    _addPauser(account);
  }

  function renouncePauser(address account) public onlyPauser {
    require(account == msg.sender && account != owner());
    _removePauser(account);
  }

  function removePauser(address account) public onlyOwner {
    require(account != owner());
      _removePauser(account);
    }

  function _addPauser(address account) internal {
    pausers.add(account);
    emit PauserAdded(account);
  }

  function _removePauser(address account) internal {
    pausers.remove(account);
    emit PauserRemoved(account);
  }
}


/**
 * @title PUBLCPausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract PUBLCPausable is PUBLCPauserRole {
  event Paused(address account);
  event Unpaused(address account);

  bool private _paused;

  constructor() internal {
    _paused = false;
  }

  /**
   * @return true if the contract is paused, false otherwise.
   */
  function paused() public view returns(bool) {
    return _paused;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!_paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(_paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyPauser whenNotPaused {
    _paused = true;
    emit Paused(msg.sender);
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyPauser whenPaused {
    _paused = false;
    emit Unpaused(msg.sender);
  }
}


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

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

interface IERC20Extension {

    function increaseAllowance(
        address spender,
        uint256 addedValue
    )
    external
    returns (bool);

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    )
    external
    returns (bool);
}

/**
 * @title PUBLCEntity
 *
 * A standard PUBLC contract for validation and versioning purposes
 */
contract PUBLCEntity {
    string private _name;
    string private _version;

    /**
     * Constructor for PUBLCEntity contract
     * @param name The name of the contract
     * @param version The version of the contract
     */
    constructor(string name, string version) public {
        _name = name;
        _version = version;
    }

    /**
     * Validates the contract's name and version
     * @param name The new PUBLCEntity's name to validate
     * @param version The new PUBLCEntity's version to validate
     */
    function validate(string name, string version) public view {
        require(uint(keccak256(abi.encodePacked(_name))) == uint(keccak256(abi.encodePacked(name))));
        require(uint(keccak256(abi.encodePacked(_version))) == uint(keccak256(abi.encodePacked(version))));
    }

    function name() public view returns (string) { return _name; }
    function version() public view returns (string) { return _version; }
}



/**
 * @title PUBLCAccount
 *
 * A contract account managed by PUBLC, which holds token funds and performs all ERC20 functionalities.
 */
contract PUBLCAccount is PUBLCEntity, PUBLCPausable, PUBLCProxied {

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



/**
 * @title Reserve
 *
 * A contract account managed by PUBLC, which holds token funds not yet released to circulation.
 */
contract Reserve is PUBLCAccount {
    /**
     * Constructor for Reserve contract
     * @param proxy The address of PUBLC contract, which has permission to perform actions on this contract
     */
    constructor(address proxy) public PUBLCEntity("Reserve", "1.0.0") PUBLCAccount(proxy) {}
}


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
    event SetNewPublc(address currentPublcAddress, address newPublcAddress, string version);

    /**
     * Constructor for PUBLC contract
     * @param proxy The address of PUBLC platform's account which signs the transactions
     */
    constructor(address proxy) public PUBLCEntity("PUBLC", "1.0.1") {
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
        PUBLCAccount(_reserveAddress).addPauser(newPublc);
        PUBLCAccount(_reserveAddress).renouncePauser(this);
        PUBLCAccount(_escrowAddress).addPauser(newPublc);
        PUBLCAccount(_escrowAddress).renouncePauser(this);
        pause();
        emit SetNewPublc(this, newPublc, version);
    }

    /**
     * Performs a transaction that syncs PUBLC platform's ledger with Ethereum.
     * @param publcTxId The transaction ID in PUBLC platform's ledger
     * @param from The sender contract's address
     * @param to The receiver's address
     * @param value The value of the tokens to be sent
     */
    function doPublcTransaction(string publcTxId, address from, address to, uint256 value) public onlyProxyOrOwner whenNotPaused {
        require(from == _reserveAddress && to == _escrowAddress);
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
