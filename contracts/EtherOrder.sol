pragma solidity ^0.4.16;

import "./Shop.sol";
import "./IOrder.sol";

contract EtherOrder is IOrder {

  uint256 productPriceInWei;
  uint256 stock;
  
  mapping(uint256 => OrderStatus) productStatus;
  mapping(address => uint256) personProduct; // order one product only
  
  function order(uint256 _productId, address _shopAddress) public payable returns (bool) {
    require(_productId != 0);
    require(productStatus[_productId] == OrderStatus.Confirmed);
    require(personProduct[msg.sender] == 0);
    require(msg.value > 0);
    require(_shopAddress != address(0));
    
    Shop shop = Shop(_shopAddress);
    
    (productPriceInWei, ) = shop.getProductInfo(_productId);
    if (msg.value > productPriceInWei) {
      msg.sender.transfer(msg.value - productPriceInWei); 
    }

    productStatus[_productId] = OrderStatus.Pending;
    personProduct[msg.sender] = _productId;
    
    OrderPlaced(_productId, _shopAddress, msg.sender, productPriceInWei, OrderStatus.Pending);
    return true;
  }
  
  function comfirmOrder(uint256 _productId, address _shopAddress) public returns (bool) {
    Shop shop = Shop(_shopAddress);
    require(msg.sender == shop.getOwner());
    
    (productPriceInWei, stock) = shop.getProductInfo(_productId);
    _shopAddress.transfer(productPriceInWei);
    
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
    (productPriceInWei, ) = shop.getProductInfo(_productId);
    msg.sender.transfer(productPriceInWei);
    personProduct[msg.sender] = 0;

    Withdraw(_productId, _shopAddress, msg.sender);
    return true;
  }
}