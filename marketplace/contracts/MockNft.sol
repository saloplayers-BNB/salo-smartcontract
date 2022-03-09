// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MockNft is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private tokenCounter;
    constructor(
    ) ERC721("Mock NFT", "NFT") {
    }

    function mint(address _to) external {
        tokenCounter.increment();
        uint256 newId = tokenCounter.current();

        _safeMint(_to, newId);
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
}
