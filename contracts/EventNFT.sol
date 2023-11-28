// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

contract EventNFT is
    ERC721,
    ERC721Enumerable,
    ERC721Pausable,
    Ownable,
    ERC721Burnable
{
    uint256 private _nextTokenId;
    string private _uri;
    uint256 public cost;

    constructor(
        string memory name,
        string memory symbol,
        address initialOwner,
        string memory baseUri
    ) ERC721(name, symbol) Ownable(initialOwner) {
        _uri = baseUri;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function setCost(uint256 newCost) public onlyOwner {
        cost = newCost;
    }

    function mint() public payable whenNotPaused {
        require(msg.value == cost, "invalid cost");
        uint256 tokenId = ++_nextTokenId;
        _safeMint(_msgSender(), tokenId);
    }

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }

    function claim(address user, uint256[] calldata tokenIds) public onlyOwner {
        require(tokenIds.length == 7, "invalid set of tokens");
        require(isApprovedForAll(user, _msgSender()), "not alloweded");
        uint256 index;
        for (index = 0; index < tokenIds.length; index++) {
            require(_ownerOf(tokenIds[index]) == user, "invalid token id");
        }
        for (index = 0; index < tokenIds.length; index++) {
            super._burn(tokenIds[index]);
        }
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        _requireOwned(tokenId);

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string.concat(baseURI, Strings.toString(tokenId))
                : "";
    }

    function setBaseURI(string calldata newBaseURI) public onlyOwner {
        _uri = newBaseURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return _uri;
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address to,
        uint256 tokenId,
        address auth
    )
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(
        address account,
        uint128 value
    ) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
