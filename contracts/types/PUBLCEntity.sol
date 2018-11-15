pragma solidity ^0.4.24;

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
