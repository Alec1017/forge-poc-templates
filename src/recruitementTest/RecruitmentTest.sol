pragma solidity ^0.8.15;

contract Storage1 {
    address public owner;

    mapping(address => bytes32) public authUsers;
    mapping(bytes32 => address) private _authUserLookup;

    uint256 public important;

    event impSet(address _sender, uint256 _value);

    constructor() {
        // set msg.sender as the owner
        owner = msg.sender;
    }

    modifier onlyAuthUsers {
        require(authUsers[msg.sender].length != 0, "user not authorized");
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "only accessible by owner");
        _;
    }

    function authUserLookup(bytes calldata _name) external view returns (address) {
        // create a hash of the byte name
        bytes32 nameHash = keccak256(_name);

        return _authUserLookup[nameHash];
    }

    function addAuthUser(address _authUser, bytes calldata _name) public onlyOwner {


        // create a hash of the byte name
        bytes32 nameHash = keccak256(_name);

        authUsers[_authUser] = nameHash;
        _authUserLookup[nameHash] = _authUser;
    }

    function revokeAuthUser(address _authUser) public onlyOwner {

        bytes32 nameHash = authUsers[_authUser];

        keccak256(abi.encode(msg.sender));
        keccak256(abi.encodePacked(msg.sender));

        delete authUsers[_authUser];
        delete _authUserLookup[nameHash];
    }

    function setImportant(uint256 _important) external onlyAuthUsers onlyOwner {
        important = _important;
        emit impSet(msg.sender, _important);
    }
}
