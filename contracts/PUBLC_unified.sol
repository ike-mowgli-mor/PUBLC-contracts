pragma solidity ^0.4.24;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
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
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
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


contract PauserRole {
  using Roles for Roles.Role;

  event PauserAdded(address indexed account);
  event PauserRemoved(address indexed account);

  Roles.Role private pausers;

  constructor() internal {
    _addPauser(msg.sender);
  }

  modifier onlyPauser() {
    require(isPauser(msg.sender));
    _;
  }

  function isPauser(address account) public view returns (bool) {
    return pausers.has(account);
  }

  function addPauser(address account) public onlyPauser {
    _addPauser(account);
  }

  function renouncePauser() public {
    _removePauser(msg.sender);
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

interface IERC20Allowance {

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


/**
 * @title proxy
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


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
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

contract PublcEntity {
    string private _name;
    string private _version;

    constructor(string name, string version) public {
        _name = name;
        _version = version;
    }

    function validate(string name, string version) public view {
        require(uint(keccak256(abi.encodePacked(_name))) == uint(keccak256(abi.encodePacked(name))));
        require(uint(keccak256(abi.encodePacked(_version))) == uint(keccak256(abi.encodePacked(version))));
    }

    function name() public view returns (string) { return _name; }
    function version() public view returns (string) { return _version; }
}



contract PublcAccount is PublcEntity, Pausable, Proxied {

    constructor(address proxy) public {
        transferProxy(proxy);
        addPauser(proxy);
    }

    function transfer(address tokenAddress, address to, uint256 value) public onlyProxyOrOwner whenNotPaused returns(bool) {
        return IERC20(tokenAddress).transfer(to, value);
    }

    function approve(address tokenAddress, address spender, uint256 value)
    public onlyProxyOrOwner whenNotPaused returns (bool) {
        return IERC20(tokenAddress).approve(spender, value);
    }
    function transferFrom(address tokenAddress, address from, address to, uint256 value)
    public onlyProxyOrOwner whenNotPaused returns (bool) {
        return IERC20(tokenAddress).transferFrom(from, to, value);
    }
    function increaseAllowance(
        address tokenAddress,
        address spender,
        uint256 addedValue
) public onlyProxyOrOwner whenNotPaused returns (bool) {
        return IERC20Allowance(tokenAddress).increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(
        address tokenAddress,
        address spender,
        uint256 subtractedValue
) public onlyProxyOrOwner whenNotPaused returns (bool) {
        return IERC20Allowance(tokenAddress).decreaseAllowance(spender, subtractedValue);
    }
}

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


contract Escrow is PUBLCAccount {
    constructor(address proxy) public PublcEntity("Escrow", "1.0.0") PUBLCAccount(proxy) {}
}



contract Reserve is PUBLCAccount {
    constructor(address proxy) public PublcEntity("Reserve", "1.0.0") PUBLCAccount(proxy) {}
}


contract PUBLC is PublcEntity, Pausable, Proxied {
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
    mapping (string => PublcTransaction) _publcTransactions;

    constructor(address proxy) public PublcEntity("Publc", "1.0.0") {
        transferProxy(proxy);
    }

    event PublcTransactionEvent(string publxId, address from, address to, uint256 value);

    event PublcError(string);

    function circulatingSupply() public view returns(uint256) {
        IERC20 token = IERC20(_tokenAddress);
        return token.totalSupply().sub(token.balanceOf(_reserveAddress));
    }

    function setTokenAddress(address tokenAddress) public onlyOwner whenNotPaused { _tokenAddress = tokenAddress; }

    function setEscrow(address newEscrowAddress, string version)
    public
    onlyOwner
    whenNotPaused {

        setNewPublcAccount(_escrowAddress, newEscrowAddress, "Escrow", version);
        _escrowAddress = newEscrowAddress;
    }

    function setReserve(address newReserveAddress, string version)
    public
    onlyOwner
    whenNotPaused {

        setNewPublcAccount(_reserveAddress, newReserveAddress, "Reserve", version);
        _reserveAddress = newReserveAddress;
    }
    function setNewPublcAccount(address currAccount, address newAccount, string name, string version) internal onlyOwner whenNotPaused {

        // Validating the new PublcEntity
        PublcEntity(newAccount).validate(name, version);

        if (currAccount != address(0)) {
            uint256 balance = IERC20(_tokenAddress).balanceOf(currAccount);
            PUBLCAccount paCurrAccount = PUBLCAccount(currAccount);
            paCurrAccount.transfer(_tokenAddress, newAccount, balance);
            paCurrAccount.pause();
        }
    }

    function tokenAddress() public view returns (address) { return _tokenAddress; }
    function escrowAddress() public view returns (address) { return _escrowAddress; }
    function reserveAddress() public view returns (address) { return _reserveAddress; }

    function doPublcTransaction(string publcTxId, address from, address to, uint256 value) public onlyProxyOrOwner whenNotPaused {

        if (from == _reserveAddress || from == _escrowAddress) {
            require(value > 0);
            require(_publcTransactions[publcTxId].value == 0);
            PUBLCAccount(from).transfer(_tokenAddress, to, value);
            _publcTransactions[publcTxId] = PublcTransaction(publcTxId, from, to, value);
            emit PublcTransactionEvent(publcTxId, from, to, value);
        }
        else {
            emit PublcError("Unsupported PUBLC transaction. Currently only supporting transactions from Reserve or Escrow");
            revert();
        }
    }
    function publcTx(string publcTxId) public view returns (address, address, uint256) {
        return (_publcTransactions[publcTxId].from, _publcTransactions[publcTxId].to, _publcTransactions[publcTxId].value);
    }

    function retire(address newPublc, string version) public onlyOwner whenNotPaused {

        // Validating the new Publc
        PublcEntity(newPublc).validate("Publc", version);
        PUBLCAccount(_reserveAddress).transferProxy(newPublc);
        PUBLCAccount(_escrowAddress).transferProxy(newPublc);
        pause();
    }
}