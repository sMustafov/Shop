pragma solidity ^0.4.16;

import "./IOrder.sol";

contract IEtherOrder is IOrder {

  function etherOrder(uint256 _productId, address _shopAddress) public payable returns (bool);

  function etherComfirmOrder(uint256 _productId, address _shopAddress) public returns (bool success);

  function etherWithdrawPayment(uint256 _productId, address _shopAddress) public returns (bool success);
}