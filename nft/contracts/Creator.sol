// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IExtendERC721.sol";

contract Creator is Ownable, Pausable {
    IERC20 public acceptedToken;
    uint256 public fee;
    address public signer;
    mapping(uint8 => address) nftAddresses;

    event Created(
        address indexed nftAddress,
        uint256 tokenId
    );

    constructor(
        uint256 _fee,
        address _acceptedToken,
        address _characterSmartContract,
        address _fragmentSmartContract,
        address _itemSmartContract,
        address _weaponSmartContract
    ) {
        fee = _fee;
        setAcceptedToken(_acceptedToken);
        setNFTAddresses(
            _characterSmartContract,
            _fragmentSmartContract,
            _itemSmartContract,
            _weaponSmartContract
        );
    }

    function setAcceptedToken(address _acceptedToken) public onlyOwner {
        acceptedToken = IERC20(_acceptedToken);
    }

    function setFee(uint256 _fee) public onlyOwner {
        fee = _fee;
    }

    function setSigner(address _signer) public onlyOwner {
        signer = _signer;
    }

    function setNFTAddresses(
        address _characterSmartContract,
        address _fragmentSmartContract,
        address _itemSmartContract,
        address _weaponSmartContract
    ) internal {
        nftAddresses[1] = _characterSmartContract;
        nftAddresses[2] = _fragmentSmartContract;
        nftAddresses[3] = _itemSmartContract;
        nftAddresses[4] = _weaponSmartContract;
    }

    /// @notice nftType
    /// 1. Character
    /// 2. Fragment
    /// 3. Item
    /// 4. Weapon
    function create(
        uint8 nftType,
        string memory metadataId,
        bytes memory signature
    ) public whenNotPaused returns (uint256) {
        address _sender = _msgSender();

        bytes32 hash = ECDSA.toEthSignedMessageHash(
            keccak256(abi.encode(nftType, metadataId, _sender))
        );
        address recovered = ECDSA.recover(hash, signature);

        require(signer == recovered, "Creator: invalid signature");

        if (fee == 0 || acceptedToken.transferFrom(_sender, owner(), fee)) {
            address nftAddress = nftAddresses[nftType];

            if (nftAddress == address(0)) {
                revert("Creator: invalid nft type");
            } else {
                try IExtendERC721(nftAddress).mint(_sender, metadataId) returns (
                    uint256 tokenId
                ) {

                    emit Created(
                        nftAddress,
                        tokenId
                    );
                    return tokenId;
                } catch {
                    revert("Creator: failed to mint a nft");
                }
            }
        } else {
            revert("Creator: failed to transfer fee to owner");
        }
    }

    function pause() public onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() public onlyOwner whenPaused {
        _unpause();
    }
}
