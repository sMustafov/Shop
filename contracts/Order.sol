pragma solidity ^0.4.16;

import "./Shop.sol";
import "./IOrder.sol";

contract Order is IOrder {

  uint256 productPriceInEth;
  uint256 stock;
  
  mapping(uint256 => OrderStatus) productStatus;
  mapping(address => uint256) personProduct;
  
  function etherOrder(uint256 _productId, address _shopAddress) public payable returns (bool) {
    require(_productId != 0);
    require(productStatus[_productId] == OrderStatus.Confirmed);
    require(personProduct[msg.sender] == 0);
    require(msg.value > 0);
    require(_shopAddress != address(0));
    
    Shop shop = Shop(_shopAddress);
    
    (productPriceInEth, , ,) = shop.getProductInfo(_productId);
    if (msg.value > productPriceInEth) {
      msg.sender.transfer(msg.value - productPriceInEth); 
    }

    productStatus[_productId] = OrderStatus.Pending;
    personProduct[msg.sender] = _productId;
    
    EthereumOrderPlaced(_productId, _shopAddress, msg.sender, productPriceInEth, OrderStatus.Pending);
    return true;
  }
  
  function comfirmOrder(uint256 _productId, address _shopAddress) public returns (bool) {
    Shop shop = Shop(_shopAddress);
    require(msg.sender == shop.getOwner());
    
    (productPriceInEth, stock, , ) = shop.getProductInfo(_productId);
    _shopAddress.transfer(productPriceInEth);
    
    stock--;
    productStatus[_productId] = OrderStatus.Confirmed;
    
    EthereumOrderPlaced(_productId, _shopAddress, msg.sender, productPriceInEth, OrderStatus.Confirmed);
    return true;
  }

  function withdrawPayment(uint256 _productId, address _shopAddress) public returns (bool success) {
    require(_productId != 0);
    require(productStatus[_productId] == OrderStatus.Pending);  
    require(personProduct[msg.sender] == 0);
    
    Shop shop = Shop(_shopAddress);
    (productPriceInEth, , , ) = shop.getProductInfo(_productId);
    msg.sender.transfer(productPriceInEth);
    
    return true;
  }
}