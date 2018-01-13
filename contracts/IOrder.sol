pragma solidity ^0.4.16;

contract IOrder {
  enum OrderStatus {
      Pending,
      Confirmed
  }
  
  event OrderPlaced(uint256 _productId, address _shopAddress, address _from, uint256 _price, OrderStatus _status);

  event Withdraw(uint256 _productId, address _shopAddress, address _from);
}