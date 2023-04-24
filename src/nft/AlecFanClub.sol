// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "openzeppelin-contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/utils/cryptography/ECDSA.sol";
import "openzeppelin-contracts/utils/Strings.sol";

/// @title An NFT contract for Alec's fan club
/// @author Alec DiFederico
contract AlecFanClub is ERC721Enumerable, Ownable {
    using ECDSA for bytes32;
    using Strings for uint256;

    mapping(address => uint256) public alreadyMinted;

    uint256 public constant PRICE = 0.06 ether;

    uint256 public constant MAX_SUPPLY = 7777;
    
    bool public enablePublicMint = true;

    address public publicMintingAddress;

    constructor() ERC721("AlecFanClub", "AFC") {}

    function setPublicMintAddress(address _address) external onlyOwner {
        publicMintingAddress = _address;
    }

    function setPublicMint(bool _enabled) external onlyOwner {
        enablePublicMint = _enabled;
    }

    function publicMint(bytes calldata _signature) external payable {    
        require(totalSupply() < MAX_SUPPLY, "max supply");
        require(enablePublicMint, "public mint not enabled");
        require(msg.sender == tx.origin, "cannot mint from a smart contract");
        require(
            publicMintingAddress ==
                bytes32(uint256(uint160(msg.sender)))
                    .toEthSignedMessageHash()
                    .recover(_signature),
                    
            "EOA not approved by public mint address to mint an NFT"
        );
        require(alreadyMinted[msg.sender] < 2, "limit per-address mints to 2");
        require(msg.value == 0.06 ether, "wrong price");

        alreadyMinted[msg.sender]++;
        _safeMint(msg.sender, totalSupply());
    }

}