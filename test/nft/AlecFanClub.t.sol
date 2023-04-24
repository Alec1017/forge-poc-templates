pragma solidity ^0.8.13;

import "openzeppelin-contracts/utils/cryptography/ECDSA.sol";

import "./state/BaseFundedAccount.sol";

import "../../src/nft/AlecFanClub.sol";

contract AlecFanClubTest is BaseFundedAccount {
    using ECDSA for bytes32;

    AlecFanClub public alecFanClub;

    address public publicMinterAddress = _ACCOUNT_A;
    uint256 public publicMinterAddressPrivKey = _PRIV_KEY_ACCOUNT_A;

    address public nftMinter = _ACCOUNT_B;

    function setUp() public virtual override {
        super.setUp();

        // deploy the new contract
        alecFanClub = new AlecFanClub();

        assertTrue(address(alecFanClub) != address(0));
        assertEq(alecFanClub.publicMintingAddress(), address(0));

        // set the public minter address
        alecFanClub.setPublicMintAddress(publicMinterAddress);

        assertEq(alecFanClub.publicMintingAddress(), publicMinterAddress);
    }

    function testPublicMintSuccess() public {

        // create a message to sign to allow nftMinter to mint
        bytes32 message = bytes32(uint256(uint160(nftMinter))).toEthSignedMessageHash();

        // public minter address signs the message
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(publicMinterAddressPrivKey, message);

        // create a signature from the v, r, s values
        bytes memory signature = abi.encodePacked(r, s, v);
        
        // nftMinter now executes the public mint
        vm.prank(nftMinter, nftMinter);
        alecFanClub.publicMint{value: 0.06 ether}(signature);

        // assert that the public mint worked
        assertEq(alecFanClub.totalSupply(), 1);
        assertEq(alecFanClub.alreadyMinted(nftMinter), 1);
        assertEq(alecFanClub.balanceOf(nftMinter), 1);

        // nftMinter now executes the public mint again
        vm.prank(nftMinter, nftMinter);
        alecFanClub.publicMint{value: 0.06 ether}(signature);

        // assert that the public mint worked
        assertEq(alecFanClub.totalSupply(), 2);
        assertEq(alecFanClub.alreadyMinted(nftMinter), 2);
        assertEq(alecFanClub.balanceOf(nftMinter), 2);
    }
}