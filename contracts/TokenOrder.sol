pragma solidity ^0.4.16;

import "./Shop.sol";
import "./IOrder.sol";
import "./Token/ERC20.sol";

contract EtherOrder is IOrder {
  ERC20 token;

  uint256 productPriceInTokens;
  uint256 stock;
  
  mapping(uint256 => OrderStatus) productStatus;
  mapping(address => uint256) personProduct; // order one product only
  mapping(uint256 => uint256) orderAmount;

  function order(uint256 _productId, address _shopAddress, address _tokenAddress) public returns (bool) {
    require(_productId != 0);
    require(productStatus[_productId] == OrderStatus.Confirmed);
    require(personProduct[msg.sender] == 0);
    require(_shopAddress != address(0));
    require(tokenAmount > 0);
    
    token = ERC20(_tokenAddress);

    productStatus[_productId] = OrderStatus.Pending;
    personProduct[msg.sender] = _productId;
    productPriceInTokens = shop.getProductTokenPrice(_productId, _tokenAddres);

    token.transfer(this, productPriceInTokens);
    
    OrderPlaced(_productId, _shopAddress, _tokenAddres, tokenAmount, OrderStatus.Pending);
    return true;
  }

  function comfirmOrder(uint256 _productId, address _shopAddress) public returns (bool) {
    Shop shop = Shop(_shopAddress);
    require(msg.sender == shop.getOwner());
    
    productPriceInTokens = shop.getProductTokenPrice(_productId, _tokenAddres);
    token.transfer(_shopAddress, this.balance);
    
    stock--;
    productStatus[_productId] = OrderStatus.Confirmed;
    personProduct[msg.sender] = 0;
    
    OrderPlaced(_productId, _shopAddress, msg.sender, productPriceInWei, OrderStatus.Confirmed);
    return true;
  }

  function withdrawPayment(uint256 _productId, address _shopAddress) public returns (bool success) {
    require(_productId != 0);
    require(productStatus[_productId] == OrderStatus.Pending);  
    require(personProduct[msg.sender] != 0);
    
    Shop shop = Shop(_shopAddress);
    productPriceInTokens = shop.getProductTokenPrice(_productId, _tokenAddres);
    token.transfer(_shopAddress, this.balance);
    
    personProduct[msg.sender] = 0;

    Withdraw(_productId, _shopAddress, msg.sender);
    return true;
  }
}