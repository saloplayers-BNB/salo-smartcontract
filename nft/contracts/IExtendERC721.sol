// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IExtendERC721 {
    function mint(address _to, string memory _metadataId)
        external
        returns (uint256);
}
