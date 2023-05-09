pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "foundry-vyper/utils/VyperDeployer.sol";

import "../../../vyper_contracts/interfaces/ISimpleStore.sol";

contract SimpleStoreTest is DSTest {

    VyperDeployer vyperDeployer = new VyperDeployer();

    ISimpleStore simpleStore;

    function setUp() public {
        simpleStore = ISimpleStore(
            vyperDeployer.deployContract("SimpleStore", abi.encode(1234))
        );
    }

    function testGet() public {
        uint256 val = simpleStore.get();

        require(val == 1234);
    }

    function testStore(uint256 _val) public {
        
        simpleStore.store(_val);
        uint256 val = simpleStore.get();

        require(_val == val);
    }
}