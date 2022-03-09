// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

contract MarketplaceStorage {
  struct Order {
    // Order ID
    bytes32 id;
    // Owner of the NFT
    address seller;
    // NFT registry address
    address nftAddress;
    // Price (in wei) for the published item
    uint256 price;
    // Time when this sale starts
    uint256 startSaleAt;
    // Time when this sale ends
    uint256 expiresAt;
  }

  // From ERC721 registry assetId to Order (to avoid asset collision)
  mapping (address => mapping(uint256 => Order)) public orderByAssetId;

  uint256 public ownerCutPerMillion;
  uint256 public publicationFeeInWei;

  bytes4 public constant ERC721_Interface = bytes4(0x80ac58cd);

  // EVENTS
  event OrderCreated(
    address indexed seller,
    address indexed nftAddress,
    uint256 indexed assetId,
    bytes32 id,
    uint256 priceInWei,
    uint256 startSaleAt,
    uint256 expiresAt
  );
  event OrderSuccessful(
    address indexed buyer,
    address indexed nftAddress,
    uint256 indexed tokenId,
    bytes32 id,
    uint256 totalPrice
  );
  event OrderCancelled(
    address indexed nftAddress,
    uint256 indexed tokenId,
    bytes32 id
  );

  event ChangedPublicationFee(uint256 publicationFee);
  event ChangedOwnerCutPerMillion(uint256 ownerCutPerMillion);
}
