pragma solidity ^0.4.24;

import "../Roles.sol";
import "../../types/PUBLCOwnable.sol";

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