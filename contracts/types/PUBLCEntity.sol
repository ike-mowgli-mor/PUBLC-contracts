pragma solidity ^0.4.24;

contract PUBLCEntity {
    string private _name;
    string private _version;

    /**
     * Constructor for PUBLC contract
     * @param proxy address The address of PUBLC platform's account which performs the transactions
     */
    constructor(string name, string version) public {
        _name = name;
        _version = version;
    }

    /**
     * Validates the contract's name and version
     * @param version name The new PUBLC's name to validate
     * @param version string The new PUBLC's version to validate
     */
    function validate(string name, string version) public view {
        require(uint(keccak256(abi.encodePacked(_name))) == uint(keccak256(abi.encodePacked(name))));
        require(uint(keccak256(abi.encodePacked(_version))) == uint(keccak256(abi.encodePacked(version))));
    }

    function name() public view returns (string) { return _name; }
    function version() public view returns (string) { return _version; }
}
