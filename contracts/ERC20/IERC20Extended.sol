pragma solidity ^0.4.24;

interface IERC20Extended{

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