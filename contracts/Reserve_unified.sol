pragma solidity ^0.4.24;


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
 * @title Proxied
 * @dev The proxy contract has a proxy address, and provides basic authorization control
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
     * @dev Allows the current proxy to relinquish control of the contract.
     * @notice Renouncing to proxy will leave the contract without an proxy.
     * It will only be possible to call the functions with the `onlyProxyOrOwner` modifier using the owner.
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
     * @param name The version of the contract
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

/**
 * @title Reserve
 *
 * A contract account managed by PUBLC, which holds token funds not yet released to circulation.
 */
contract Reserve is PUBLCAccount {
    /**
     * Constructor for Escrow contract
     * @param proxy The address of PUBLC contract, which has permission to perform actions on this contract
     */
    constructor(address proxy) public PUBLCEntity("Reserve", "1.0.0") PUBLCAccount(proxy) {}
}
