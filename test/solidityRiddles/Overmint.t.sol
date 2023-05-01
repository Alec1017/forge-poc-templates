pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../../src/solidityRiddles/Overmint.sol";
import "../../src/solidityRiddles/OvermintAttack.sol";

contract FlashLoanTest is Test {

    Overmint public overmint;
    OvermintAttack public overmintAttack;

    function setUp() public {

        // deploy overmint contract
        overmint = new Overmint();

        // deploy overmint attack contract
        overmintAttack = new OvermintAttack(address(overmint));
    }

    function testAttack() public {
        overmintAttack.attack();

        // sanity check that 5 NFTs were minted
        assertEq(overmint.balanceOf(address(overmintAttack)), 5);
    }
}