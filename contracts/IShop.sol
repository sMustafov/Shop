pragma solidity ^0.4.16;

contract IShop {
  event ProductAdded(uint256 indexed _id, uint256 _price, uint256 _stock);
  
  event ProductTokenPriceSet(address indexed _tokenAddress, uint256 _priceInTokens, uint256 indexed _id);
  
  event ProductRemoved(uint256 indexed _id);

  event ProductBought(address indexed _buyer, uint256 indexed _id);

  function buyProduct(uint256 id) payable public returns (bool);
  
  function getProductInfo(uint id) view public returns (uint256 priceInWei, uint256 stock);

  function getProductTokenPrice(uint256 id, address tokenAddress) view public returns (uint256 tokenPrice);
}