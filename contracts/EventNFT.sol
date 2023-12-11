// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
/**
 * Used to delegate ownership of a contract to another address, to save on unneeded transactions to approve contract use for users
 */
import "./Abstracts.sol";

// contract MyToken is Pausable, Ownable, ERC721Burnable, ERC721Enumerable {
contract EventNFT is ERC721, Ownable, ERC721Burnable, ERC721Enumerable {
    bytes32 public merkleRoot;

    uint256 public cost = 1 ether;
    uint256 public maxSupply = 100;
    uint256 public _maxMintAmount = 1; // amount per session
    uint256 public nftPerAddressLimit = 100; // limit per account
    uint256 private _mintStartBlock;
    uint256 private _mintEndBlock = 2000000000;
    bool private onlyWhitelisted = false; // doesn't have view method
    bool private _isRevealed = false;
    bool private _allowExternalTrade = true;
    string private _preRevealURI;
    string private _postRevealBaseURI;
    string public baseExtension = ".json";

    address public proxyRegistryAddress;

    uint256 private _tokenIds;
    uint256 private _currentRound;

    uint256 public volume = 7;

    mapping(uint256 => mapping(address => uint256)) public addressMintedBalance;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI,
        string memory _initNotRevealUri,
        address _proxyRegistryAddress
    ) ERC721(_name, _symbol) {
        setBaseURI(_initBaseURI);
        setPreRevealedURI(_initNotRevealUri);
        _tokenIds = 1; // start from 1
        proxyRegistryAddress = _proxyRegistryAddress;
    }

    event Revealed(string baseURI);
    event CostChanged(uint256 cost);
    event MaxSupplyChanged(uint256 maxSupply);
    event NftPerAddressLimitChanged(uint256 limit);
    event MaxMintAmountChanged(uint256 limit);
    event MintRoundBlockChanged(uint256 startBlockTime, uint256 endBlockTime);
    event WhitelistStateChanged(bool state);
    event Withdraw(uint256 amount);
    event MerkelRootChanged();
    event NftClaim(address indexed owner);

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        _postRevealBaseURI = _newBaseURI;
    }

    function setBaseExtension(
        string memory _newBaseExtension
    ) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function setPreRevealedURI(string memory _notRevealedURI) public onlyOwner {
        _preRevealURI = _notRevealedURI;
    }

    function validateMintRequest(address to, uint256 quantity) internal {
        require(quantity > 0, "at least 1");
        uint256 _currentSupply = super.totalSupply();
        require(_currentSupply + quantity <= maxSupply, "limit exceeded");
        if (msg.sender != owner()) {
            require(quantity <= _maxMintAmount, "per session exceeded");
            require(
                block.timestamp >= _mintStartBlock &&
                    block.timestamp <= _mintEndBlock,
                "not available now"
            );
            require(msg.value == cost * quantity, "insufficient funds");
        }
        if (to != owner()) {
            uint256 ownerMintedCount = addressMintedBalance[_currentRound][to];
            require(
                ownerMintedCount + quantity <= nftPerAddressLimit,
                "per address exceeded"
            );
            addressMintedBalance[_currentRound][to] =
                ownerMintedCount +
                quantity;
        }
    }

    function transferTokens(address to, uint256 quantity) internal {
        for (uint256 i; i < quantity; i++) {
            uint256 tokenId = _tokenIds;
            _safeMint(to, tokenId);
            _tokenIds++;
        }
    }

    function mintTo(address to, uint256 quantity) public payable {
        require(onlyWhitelisted == false, "not public");
        require(
            msg.sender == to || msg.sender == owner(),
            "invalid recv account"
        );
        validateMintRequest(to, quantity);
        transferTokens(to, quantity);
    }

    function whitelistMintTo(
        address to,
        uint256 quantity,
        bytes32[] calldata merkleProof
    ) public payable {
        require(onlyWhitelisted == true, "not whitelist");
        require(
            msg.sender == to || msg.sender == owner(),
            "invalid recv account"
        );
        bytes32 node = keccak256(abi.encodePacked(to));
        require(
            MerkleProof.verify(merkleProof, merkleRoot, node) == true,
            "user is not whitelisted"
        );
        validateMintRequest(to, quantity);
        transferTokens(to, quantity);
    }

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }

    function setVolume(uint256 newVolume) public onlyOwner {
        volume = newVolume;
    }

    // Call by token owner only
    function claim(uint256[] calldata tokenIds) public {
        uint256 index;
        require(tokenIds.length == volume, "invalid set of tokens");
        for (index = 0; index < tokenIds.length; index++) {
            require(ownerOf(tokenIds[index]) == _msgSender());
        }
        for (index = 0; index < tokenIds.length; index++) {
            _burn(tokenIds[index]);
        }

        emit NftClaim(_msgSender());
    }

    function tokenURI(
        uint256 _tokenId
    ) public view override returns (string memory) {
        require(_ownerOf(_tokenId) != address(0), "nonexistent token");

        string memory currentBaseURI = _isRevealed ? _baseURI() : _preRevealURI;
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        Strings.toString(_tokenId),
                        baseExtension
                    )
                )
                : "";
    }

    function reveal(string memory _newBaseURI) external onlyOwner {
        require(_isRevealed == false, "already revealed!");
        _postRevealBaseURI = _newBaseURI;
        _isRevealed = true;

        emit Revealed(_newBaseURI);
    }

    function revealed() public view returns (bool) {
        return _isRevealed;
    }

    function setTokenIds(uint256 tokenId) public onlyOwner {
        _tokenIds = tokenId;
    }

    function setCurrentRound(uint256 round) public onlyOwner {
        _currentRound = round;
    }

    function setCost(uint256 newCost) public onlyOwner {
        cost = newCost;
        emit CostChanged(cost);
    }

    function setMaxSupply(uint256 newMaxSupply) public onlyOwner {
        maxSupply = newMaxSupply;
        emit MaxSupplyChanged(maxSupply);
    }

    function setMaxMintAmount(uint256 _newMaxMintAmount) public onlyOwner {
        _maxMintAmount = _newMaxMintAmount;
        emit MaxMintAmountChanged(_maxMintAmount);
    }

    function getMaxMintAmount() public view returns (uint256) {
        return _maxMintAmount;
    }

    function setMintRoundBlock(
        uint256 startBlock,
        uint256 endBlock
    ) public onlyOwner {
        _mintStartBlock = startBlock;
        _mintEndBlock = endBlock;
        emit MintRoundBlockChanged(_mintStartBlock, _mintEndBlock);
    }

    function mintRoundBlock() public view returns (uint256, uint256) {
        return (_mintStartBlock, _mintEndBlock);
    }

    function setOnlyWhitelisted(bool _state) public onlyOwner {
        onlyWhitelisted = _state;
        emit WhitelistStateChanged(_state);
    }

    function setMerkleRoot(bytes32 _newMerkleRoot) public onlyOwner {
        merkleRoot = _newMerkleRoot;
        _currentRound++;
        emit MerkelRootChanged();
    }

    function getCurrentRound() public view returns (uint256) {
        return _currentRound;
    }

    function isWhitelisted(
        bytes32[] calldata merkleProof
    ) public view returns (bool) {
        bytes32 node = keccak256(abi.encodePacked(msg.sender));
        return MerkleProof.verify(merkleProof, merkleRoot, node) == true;
    }

    function setNftPerAddressLimit(uint256 _limit) public onlyOwner {
        nftPerAddressLimit = _limit;
        emit NftPerAddressLimitChanged(nftPerAddressLimit);
    }

    function withdraw() public payable onlyOwner {
        emit Withdraw(address(this).balance);
        (bool os, ) = payable(msg.sender).call{value: address(this).balance}(
            ""
        );
        require(os);
    }

    function _baseURI() internal view override returns (string memory) {
        return _postRevealBaseURI;
    }

    // trading restriction
    function setProxyRegistryAddress(
        address _proxyRegistryAddress
    ) public onlyOwner {
        proxyRegistryAddress = _proxyRegistryAddress;
    }

    function setAllowExternalTrade(bool _allow) public onlyOwner {
        _allowExternalTrade = _allow;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override(ERC721, IERC721) {
        require(
            _allowExternalTrade == true ||
                isApprovedForAll(from, msg.sender) == true,
            "not allowed"
        );
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override(ERC721, IERC721) {
        require(
            _allowExternalTrade == true ||
                isApprovedForAll(from, msg.sender) == true,
            "not allowed"
        );
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override(ERC721, IERC721) {
        require(
            _allowExternalTrade == true ||
                isApprovedForAll(from, msg.sender) == true,
            "not allowed"
        );
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function isApprovedForAll(
        address owner,
        address operator
    ) public view override(ERC721, IERC721) returns (bool) {
        if (_allowExternalTrade == true) {
            return super.isApprovedForAll(owner, operator);
        }
        // Whitelist WEnFT proxy contract for easy trading.
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        require(
            address(proxyRegistry.proxies(owner)) == operator,
            "only proxied account allowed"
        );
        return true;
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // function _update(
    //     address to,
    //     uint256 tokenId,
    //     address auth
    // ) internal override(ERC721, ERC721Enumerable) returns (address) {
    //     return super._update(to, tokenId, auth);
    // }

    // function _increaseBalance(
    //     address account,
    //     uint128 value
    // ) internal override(ERC721, ERC721Enumerable) {
    //     super._increaseBalance(account, value);
    // }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
