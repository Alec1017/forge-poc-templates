// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../utils/TokenUtils.sol";

contract BaseMainnetFork is TokenUtils {

    uint256 mainnetFork;

    function setUp() public virtual {
        mainnetFork = vm.createFork("eth");
        vm.selectFork(mainnetFork);

        assertEq(vm.activeFork(), mainnetFork);
    }
}