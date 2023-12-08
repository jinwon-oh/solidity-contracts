// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
/**
 * Used to delegate ownership of a contract to another address, to save on unneeded transactions to approve contract use for users
 */
import "./Abstracts.sol";

// contract MyToken is Pausable, Ownable, ERC721Burnable, ERC721Enumerable {
contract DefNFT is ERC721, Ownable, ERC721Burnable, ERC721Enumerable {
    // bytes32 immutable public merkleRoot;
    bytes32 public merkleRoot;

    uint256 public cost = 1 ether;
    uint256 public maxSupply;
    uint256 public _maxMintAmount; // amount per session
    uint256 public nftPerAddressLimit; // limit per account
    uint256 private _mintStartBlock;
    uint256 private _mintEndBlock;
    bool private onlyWhitelisted = true; // doesn't have view method
    bool private _isRevealed = false;
    bool private _allowExternalTrade = false;
    string private _preRevealURI = "";
    string private _postRevealBaseURI = "";
    // uint256 constant private BIN_SIZE = 1000;
    // uint256 private numBins = maxSupply / BIN_SIZE;

    // // 전체 bin을 관리하는 mapping
    // mapping(uint256 => uint256) private _bins;

    string public baseExtension = ".json";

    address public proxyRegistryAddress;
    // address public editor;

    // bytes32 private constant EDITOR_ROLE = keccak256("Edit");

    uint256 private _tokenIds;
    uint256 private _currentRound;

    mapping(uint256 => mapping(address => uint256)) public addressMintedBalance;

    // mapping(uint256 => mapping(address => bool)) public claimed;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI,
        string memory _initNotRevealUri,
        address _proxyRegistryAddress
    )
        // uint256 _maxSupply
        // bytes32 _merkleRoot
        ERC721(_name, _symbol)
    {
        // _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        // _setRoleAdmin(EDITOR_ROLE, DEFAULT_ADMIN_ROLE);
        // _setupRole(EDITOR_ROLE, msg.sender);

        setBaseURI(_initBaseURI);
        setPreRevealedURI(_initNotRevealUri);
        // setMaxSupply(_maxSupply);
        // setMerkleRoot(_merkleRoot);
        _tokenIds = 1; // start from 1
        proxyRegistryAddress = _proxyRegistryAddress;
    }

    // // constructor() ERC721("WEnFT Template", "WFTT") {}
    // /// @dev Restricted to members of the admin role.
    // modifier onlyAdmin() {
    //     require(isAdmin(msg.sender), "admin only");
    //     _;
    // }
    // /// @dev Restricted to members of the editor role.
    // modifier onlyEditor() {
    //     require(isEditor(msg.sender), "editor only");
    //     _;
    // }

    // /// @dev Return `true` if the account belongs to the admin role.
    // function isAdmin(address account) public view virtual returns (bool) {
    //     return hasRole(DEFAULT_ADMIN_ROLE, account);
    // }

    // /// @dev Return `true` if the account belongs to the editor role.
    // function isEditor(address account) public view virtual returns (bool) {
    //     return hasRole(EDITOR_ROLE, account);
    // }

    // /// @dev Change an account of the admin role. Restricted to admins.
    // function changeAdmin(address account) public virtual onlyAdmin {
    //     require(account != msg.sender, "is admin");
    //     require(account != 0x0000000000000000000000000000000000000000, "null account");
    //     require(account != 0x000000000000000000000000000000000000dEaD, "null account");
    //     grantRole(DEFAULT_ADMIN_ROLE, account);
    //     renounceRole(DEFAULT_ADMIN_ROLE, msg.sender);
    // }

    // /// @dev Add an account to the editor role. Restricted to admins.
    // function addEditor(address account) public virtual onlyAdmin {
    //     grantRole(EDITOR_ROLE, account);
    // }

    // /// @dev Remove an account from the editor role. Restricted to admins.
    // function removeEditor(address account) public virtual onlyAdmin {
    //     revokeRole(EDITOR_ROLE, account);
    // }

    event Revealed(string baseURI);
    event CostChanged(uint256 cost);
    event MaxSupplyChanged(uint256 maxSupply);
    event NftPerAddressLimitChanged(uint256 limit);
    event MaxMintAmountChanged(uint256 limit);
    event MintRoundBlockChanged(uint256 startBlockTime, uint256 endBlockTime);
    event WhitelistStateChanged(bool state);
    event Withdraw(uint256 amount);
    event MerkelRootChanged();

    // function pause() public onlyOwner {
    //     _pause();
    // }

    // function unpause() public onlyOwner {
    //     _unpause();
    // }

    // function setEditor(address _account) public onlyOwner {
    //     editor = _account;
    // }

    // function setBaseURI(string memory _newBaseURI) public {
    //     require(msg.sender == owner() || msg.sender == editor, "not allowed");
    //     _postRevealBaseURI = _newBaseURI;
    // }

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

    // // generate random token id
    // function transferTokens(address to, uint256 quantity) internal {
    //     uint256 i;

    //     for (i = 0; i < quantity; i++) {
    //         uint256 binIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender, i))) % numBins;
    //         // 사용 가능한 bin 선택
    //         while (_bins[binIndex] == BIN_SIZE) {
    //             binIndex = (binIndex + 1) % numBins;
    //         }

    //         // 랜덤 토큰 ID 발급
    //         uint256 tokenId = binIndex * BIN_SIZE + _bins[binIndex] + 1;
    //         _bins[binIndex]++;

    //         _safeMint(to, tokenId);
    //         _tokenIds.increment();

    //         // binIndex 업데이트
    //         if ((i + 1) % BIN_SIZE == 0) {
    //             binIndex = (binIndex + 1) % numBins;
    //         }
    //     }
    // }

    // function mint(uint256 quantity) public payable {
    //     require(onlyWhitelisted == false, "not public");
    //     validateMintRequest(msg.sender, quantity);
    //     transferTokens(msg.sender, quantity);
    // }

    // function whitelistMint(uint256 quantity, bytes32[] calldata merkleProof) public payable {
    //     // require(claimed[_currentRound.current()][msg.sender] == false, "already claimed");
    //     require(onlyWhitelisted == true, "not whitelist");
    //     bytes32 node = keccak256(abi.encodePacked(msg.sender));
    //     require(MerkleProof.verify(merkleProof, merkleRoot, node) == true, "user is not whitelisted");

    //     validateMintRequest(msg.sender, quantity);
    //     // claimed[_currentRound.current()][msg.sender] = true;

    //     transferTokens(msg.sender, quantity);
    // }

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
        // require(claimed[_currentRound.current()][to] == false, "already claimed");
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
        // claimed[_currentRound.current()][to] = true;

        transferTokens(to, quantity);
    }

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }

    function tokenURI(
        uint256 _tokenId
    ) public view override returns (string memory) {
        require(_ownerOf(_tokenId) != address(0), "nonexistent token");

        // return super.tokenURI(_tokenId);
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
        // numBins = maxSupply / BIN_SIZE;
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
