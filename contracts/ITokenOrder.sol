pragma solidity ^0.4.16;

import "./IOrder.sol";

contract ITokenOrder is IOrder {

  function tokenOrder(uint256 _productId, address _shopAddress, address _tokenAddress) public returns (bool);

  function tokenComfirmOrder(uint256 _productId, address _shopAddress, address _tokenAddress) public returns (bool success);

  function tokenWithdrawPayment(uint256 _productId, address _shopAddress, address _tokenAddress) public returns (bool success);
}