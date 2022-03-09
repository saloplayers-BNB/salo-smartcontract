// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./MarketplaceStorage.sol";

contract Marketplace is Ownable, Pausable, MarketplaceStorage, IERC721Receiver {
  using SafeMath for uint256;
  using Address for address;

  /**
    * @dev Initialize this contract. Acts as a constructor
    * @param _ownerCutPerMillion - owner cut per million
    */
  constructor (
    uint256 _ownerCutPerMillion
  )
  {
    // Fee init
    setOwnerCutPerMillion(_ownerCutPerMillion);
  }


  /**
    * @dev Sets the publication fee that's charged to users to publish items
    * @param _publicationFee - Fee amount in wei this contract charges to publish an item
    */
  function setPublicationFee(uint256 _publicationFee) external onlyOwner {
    publicationFeeInWei = _publicationFee;
    emit ChangedPublicationFee(publicationFeeInWei);
  }

  /**
    * @dev Sets the share cut for the owner of the contract that's
    *  charged to the seller on a successful sale
    * @param _ownerCutPerMillion - Share amount, from 0 to 400,000
    */
  function setOwnerCutPerMillion(uint256 _ownerCutPerMillion) public onlyOwner {
    require(_ownerCutPerMillion <= 400000, "The owner cut should be between 0 and 400,000");

    ownerCutPerMillion = _ownerCutPerMillion;
    emit ChangedOwnerCutPerMillion(ownerCutPerMillion);
  }

  /**
    * @dev Creates a new order
    * @param nftAddress - Non fungible registry address
    * @param tokenId - ID of the published NFT
    * @param priceInWei - Price in Wei for the supported coin
    * @param startSaleAt - Time to start the order
    * @param expiresAt - Time to end the order
    */
  function createOrder(
    address nftAddress,
    uint256 tokenId,
    uint256 priceInWei,
    uint256 startSaleAt,
    uint256 expiresAt
  )
    public payable
    whenNotPaused
  {
    _createOrder(
      nftAddress,
      tokenId,
      priceInWei,
      startSaleAt,
      expiresAt
    );
  }

  /**
    * @dev Cancel an already published order
    *  can only be canceled by seller or the contract owner
    * @param nftAddress - Address of the NFT registry
    * @param tokenId - ID of the published NFT
    */
  function cancelOrder(address nftAddress, uint256 tokenId) public whenNotPaused {
    _cancelOrder(nftAddress, tokenId);
  }

  /**
    * @dev Executes the sale for a published NFT
    * @param nftAddress - Address of the NFT registry
    * @param tokenId - ID of the published NFT
    */
  function executeOrder(
    address nftAddress,
    uint256 tokenId
  )
   public payable
   whenNotPaused
  {
    _executeOrder(
      nftAddress,
      tokenId,
      msg.value
    );
  }

  /**
    * @dev Creates a new order
    * @param nftAddress - Non fungible registry address
    * @param tokenId - ID of the published NFT
    * @param priceInWei - Price in Wei for the supported coin
    * @param startSaleAt - Time to start the order
    * @param expiresAt - Time to end the order
    */
  function _createOrder(
    address nftAddress,
    uint256 tokenId,
    uint256 priceInWei,
    uint256 startSaleAt,
    uint256 expiresAt
  )
    internal
  {
    _requireERC721(nftAddress);

    address sender = _msgSender();

    // Check if there's a publication fee and
    // transfer the amount to marketplace owner
    if (publicationFeeInWei > 0) {
      require(msg.value == publicationFeeInWei, "Should be equals publication fee");
    }

    IERC721 nftRegistry = IERC721(nftAddress);
    address assetOwner = nftRegistry.ownerOf(tokenId);

    require(sender == assetOwner, "Only the owner can create orders");

    // NOTE: transfer to this contract
    nftRegistry.safeTransferFrom(sender, address(this), tokenId);

    require(priceInWei > 0, "Price should be bigger than 0");
    require(startSaleAt > block.timestamp.add(1 minutes), "Publication should be more than 1 minute in the future");
    require(startSaleAt < expiresAt, "Expires timestamp should be after Start Sale timestamp");

    bytes32 orderId = keccak256(
      abi.encodePacked(
        block.timestamp,
        assetOwner,
        tokenId,
        nftAddress,
        priceInWei
      )
    );

    orderByAssetId[nftAddress][tokenId] = Order({
      id: orderId,
      seller: assetOwner,
      nftAddress: nftAddress,
      price: priceInWei,
      startSaleAt: startSaleAt,
      expiresAt: expiresAt
    });

    emit OrderCreated(
      assetOwner,
      nftAddress,
      tokenId,
      orderId,
      priceInWei,
      startSaleAt,
      expiresAt
    );
  }

  /**
    * @dev Cancel an already published order
    *  can only be canceled by seller or the contract owner
    * @param nftAddress - Address of the NFT registry
    * @param tokenId - ID of the published NFT
    */
  function _cancelOrder(address nftAddress, uint256 tokenId) internal returns (Order memory) {
    address sender = _msgSender();
    Order memory order = orderByAssetId[nftAddress][tokenId];

    require(order.id != 0, "Asset not published");
    require(order.seller == sender || sender == owner(), "Unauthorized user");

    bytes32 orderId = order.id;
    address orderSeller = order.seller;
    delete orderByAssetId[nftAddress][tokenId];

    IERC721 _nftContract = IERC721(nftAddress);
    _nftContract.safeTransferFrom(address(this), orderSeller, tokenId);

    emit OrderCancelled(
      nftAddress,
      tokenId,
      orderId
    );

    return order;
  }

  /**
    * @dev Executes the sale for a published NFT
    * @param nftAddress - Address of the NFT registry
    * @param tokenId - ID of the published NFT
    * @param price - Order price
    */
  function _executeOrder(
    address nftAddress,
    uint256 tokenId,
    uint256 price
  )
   internal returns (Order memory)
  {
    _requireERC721(nftAddress);

    address sender = _msgSender();

    IERC721 nftRegistry = IERC721(nftAddress);

    Order memory order = orderByAssetId[nftAddress][tokenId];

    require(order.id != 0, "Asset not published");

    address seller = order.seller;

    require(seller != address(0), "Invalid address");
    require(seller != sender, "Unauthorized user");
    require(order.price == price, "The price is not correct");
    require(block.timestamp >= order.startSaleAt, "The order is not started");
    require(block.timestamp < order.expiresAt, "The order expired");

    uint saleShareAmount = 0;

    bytes32 orderId = order.id;
    delete orderByAssetId[nftAddress][tokenId];

    if (ownerCutPerMillion > 0) {
      // Calculate sale share
      saleShareAmount = price.mul(ownerCutPerMillion).div(1000000);

      // Transfer sale amount to seller
      payable(seller).transfer(price.sub(saleShareAmount));
    }

    // Transfer asset owner
    nftRegistry.safeTransferFrom(
      address(this),
      sender,
      tokenId
    );

    emit OrderSuccessful(
      sender,
      nftAddress,
      tokenId,
      orderId,
      price
    );

    return order;
  }

  function _requireERC721(address nftAddress) internal view {
    require(nftAddress.isContract(), "The NFT Address should be a contract");

    IERC721 nftRegistry = IERC721(nftAddress);
    require(
      nftRegistry.supportsInterface(ERC721_Interface),
      "The NFT contract has an invalid ERC721 implementation"
    );
  }

  function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
    return this.onERC721Received.selector;
  }

  function getOrder(
    address _nftAddress,
    uint256 _tokenId
  )
    public
    view
    returns (
      bytes32 id,
      address seller,
      uint256 price,
      uint256 startSaleAt,
      uint256 expiresAt
    )
  {
    Order memory _order = orderByAssetId[_nftAddress][_tokenId];

    if(_order.id != 0)
    return (
      _order.id,
      _order.seller,
      _order.price,
      _order.startSaleAt,
      _order.expiresAt
    );
  }

  function withdraw() external onlyOwner {
    payable(owner()).transfer(address(this).balance);
  }

  function pause() public onlyOwner whenNotPaused {
    _pause();
  }

  function unpause() public onlyOwner whenPaused {
    _unpause();
  }
}
