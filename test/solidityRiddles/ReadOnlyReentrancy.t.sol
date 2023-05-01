pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../../src/solidityRiddles/ReadOnlyReentrancy.sol";

contract ReadOnlyReentrancyTest is Test {

    VulnerableDeFiContract public vulnerableDefiContract;
    ReadOnlyPool public readOnlyPool;
    AttackContract public attackContract;

    address funder = vm.addr(1);
    address funder2 = vm.addr(2);
    address attacker = vm.addr(3);

    function fundAccounts() public {
        vm.deal(funder, 100 ether);
        vm.deal(funder2, 100 ether);
        vm.deal(attacker, 100 ether);

        assertEq(funder.balance, 100 ether);
        assertEq(funder2.balance, 100 ether);
        assertEq(attacker.balance, 100 ether);
    }

    function setUp() public {

        // fund accounts
        fundAccounts();

        // deploy contracts
        readOnlyPool = new ReadOnlyPool();
        vulnerableDefiContract = new VulnerableDeFiContract(readOnlyPool);

        // fund attacker contract with 100 ether
        vm.prank(attacker);
        attackContract = new AttackContract{value: 100 ether}(address(readOnlyPool), address(vulnerableDefiContract));

        // set up the read-only contract with 10 eth -> puts LP price at 1
        vm.prank(funder);
        readOnlyPool.addLiquidity{value: 10 ether}();

        // then we can snapshot the price
        vulnerableDefiContract.snapshotPrice();

        // assert that the eth was sent to the contract
        assertEq(funder.balance, 90 ether);
        assertEq(address(readOnlyPool).balance, 10 ether);

        // assert that the LP tokens were minted
        assertEq(readOnlyPool.balanceOf(funder), 10 ether);

        // assert the LP price is expected
        assertEq(vulnerableDefiContract.lpTokenPrice(), 1e18);
    }

    function testExpectedNonAttackBehavior() public {

        // get the initial lp token price according to the vulnerable contract
        uint256 initialPrice = vulnerableDefiContract.lpTokenPrice();
                
        // funder will add liquidity
        vm.prank(funder2);
        readOnlyPool.addLiquidity{value: 100 ether}();

        // funder then removes liquidity
        vm.prank(funder2);
        readOnlyPool.removeLiquidity();

        // then we can snapshot the price
        vulnerableDefiContract.snapshotPrice();

        // get the new lp token price
        uint256 manipulatedPrice = vulnerableDefiContract.lpTokenPrice();

        // assert the attack contract's balance is back to 100 ether
        assertApproxEqAbs(address(attackContract).balance, 100 ether, 100);

        // assert the new price is the same as the initial price
        assertApproxEqAbs(manipulatedPrice, initialPrice, 100);
    }

    function testAttack() public {

        // get the initial lp token price according to the vulnerable contract
        uint256 initialPrice = vulnerableDefiContract.lpTokenPrice();
        
        // attacker will deposit all ETH to mint a bunch of lp tokens, then redeem
        attackContract.initiateAttack();

        // get the lp token price after the read-only reentrancy attack
        uint256 manipulatedPrice = vulnerableDefiContract.lpTokenPrice();

        // assert the attack contract's balance is back to 100 ether
        assertApproxEqAbs(address(attackContract).balance, 100 ether, 100);

        // assert the manipulated price is less than the initial price
        assertLt(manipulatedPrice, initialPrice);
    }
}