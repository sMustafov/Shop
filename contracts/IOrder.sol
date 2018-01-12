pragma solidity ^0.4.16;

contract IOrder {
  enum OrderStatus {
      Pending,
      Confirmed
  }
  
  event EthereumOrderPlaced(uint256 _productId, address _shopAddress, address _from, uint256 _priceInEth, OrderStatus _status);
  
  function etherOrder(uint256 _productId, address _shopAddress) public payable returns (bool);
  
  function comfirmOrder(uint256 _productId, address _shopAddress) public returns (bool);

  function withdrawPayment(uint256 _productId, address _shopAddress) public returns (bool success);
}