// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./IExtendERC721.sol";

contract ExtendERC721 is IExtendERC721, ERC721Enumerable, AccessControlEnumerable, Ownable {
    using Counters for Counters.Counter;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    Counters.Counter private tokenCounter;
    mapping(uint256 => string) public metadata;
    mapping(string => bool) private executed;
    string private baseURIExtended;

    event Created(address indexed to, uint256 indexed tokenId, string metadataId);
    event MetadataChanged(uint256 indexed tokenId, string metadataId);
    event BaseURIChanged(string indexed baseURIExtended);

    constructor(string memory name_, string memory symbol_)
        ERC721(name_, symbol_)
    {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }

    function mint(address _to, string memory _metadataId)
        external
        override
        allowMint
        returns (uint256)
    {
        tokenCounter.increment();
        uint256 newId = tokenCounter.current();

        _mint(_to, newId);
        _setMetadata(newId, _metadataId);

        emit Created(_to, newId, _metadataId);

        return newId;
    }

    function setMetadata(uint256 tokenId, string memory _metadataId)
        external
        onlyOwner
    {
        require(_exists(tokenId), "ExtendERC721: nonexistent token");
        _setMetadata(tokenId, _metadataId);
        emit MetadataChanged(tokenId, _metadataId);
    }

    function _setMetadata(uint256 tokenId, string memory metadataId) internal {
        require(!executed[metadataId], "Already metadata id");
        metadata[tokenId] = metadataId;
        executed[metadataId] = true;
    }

    function setMinterRole(address to) external onlyOwner {
        _setupRole(MINTER_ROLE, to);
    }

    function revokeMinterRole(address from) external onlyOwner {
        revokeRole(MINTER_ROLE, from);
    }

    modifier allowMint() {
        address _sender = _msgSender();
        require(
            owner() == _sender || hasRole(MINTER_ROLE, _sender),
            "Must have mint role"
        );
        _;
    }

    function setBaseURI(string memory baseURI) external onlyOwner {
        baseURIExtended = baseURI;
        emit BaseURIChanged(baseURIExtended);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURIExtended;
    }

    function walletOfOwner(
        address _owner,
        uint256 _offset,
        uint256 _limit
    ) external view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0 || _offset > tokenCount - 1) {
            return new uint256[](0);
        }

        uint256 fetchable = tokenCount - _offset;
        if (_limit > fetchable) {
            _limit = fetchable;
        }

        uint256 returnArrayIndex = 0;
        uint256[] memory tokensId = new uint256[](_limit);
        for (uint256 i = _offset; i < _offset + _limit; i++) {
            tokensId[returnArrayIndex] = tokenOfOwnerByIndex(_owner, i);
            returnArrayIndex++;
        }

        return tokensId;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlEnumerable, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function burn(uint256 tokenId) public virtual {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721Burnable: caller is not owner nor approved"
        );
        delete metadata[tokenId];
        _burn(tokenId);
    }
}
