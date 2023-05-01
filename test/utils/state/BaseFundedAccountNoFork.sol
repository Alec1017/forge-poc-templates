// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../utils/TokenUtils.sol";

contract BaseFundedAccountNoFork is TokenUtils {

    // private keys
    uint256 public _PRIV_KEY_ACCOUNT_A = 0x01;
    uint256 public _PRIV_KEY_ACCOUNT_B = 0x02;
    uint256 public _PRIV_KEY_ACCOUNT_C = 0x03;
    uint256 public _PRIV_KEY_ACCOUNT_D = 0x04;

    // EOAs
    address public _ACCOUNT_A = vm.addr(_PRIV_KEY_ACCOUNT_A);
    address public _ACCOUNT_B = vm.addr(_PRIV_KEY_ACCOUNT_B);
    address public _ACCOUNT_C = vm.addr(_PRIV_KEY_ACCOUNT_C);
    address public _ACCOUNT_D = vm.addr(_PRIV_KEY_ACCOUNT_D);

    function setUp() public virtual {

        for (uint256 i = 1; i <= 4; i++) {

            // deal native ETH to accounts
            deal(EthereumTokens.NATIVE_ASSET, vm.addr(i), 100 ether);
        
            // assert that tokens were dealt properly
            assertEq(vm.addr(i).balance, 100 ether);
        }
    }
}