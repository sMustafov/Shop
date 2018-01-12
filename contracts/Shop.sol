pragma solidity ^0.4.16;

import "./Owned.sol";
import "./IShop.sol";
import "./Order.sol";

contract Shop is Owned, IShop {

  struct Product {
    uint256 stock;
    uint256 priceInEth;
    address tokenAddress;
    uint256 priceInTokens;
  }

  mapping(address => bool) admins;
  mapping (uint256 => Product) public products;

  modifier onlyAdmin {
    require(admins[msg.sender]);
    _;
  }

  event Withdrawal(uint256 _amount);
  event Payment(address indexed _to, uint256 _amount);
  
  // Only Owner can add admin
  function addAdmin(address _adminAddress) onlyOwner public {
    admins[_adminAddress] = true;
  }

  // Only Owner can remove admin
  function removeAdmin(address _adminAddress) onlyOwner public {
    admins[_adminAddress] = false;
  }

  // Only Owner or Admin can add product
  function addProduct(uint256 _id, uint256 _price, uint256 _stock) onlyOwner onlyAdmin public returns (bool) {
    require(_id > 0);
    require(_price > 0);
    require(_stock > 0);
    require(products[_id].priceInEth != 0);

    setProductPrice(_id, _price);
    setProductStock(_id, _stock);

    ProductAdded(_id, _price, _stock);
    return true;
  }
  
  function setProductPrice(uint256 _id, uint256 _price) onlyOwner onlyAdmin public {
    products[_id].priceInEth = _price;
  }

  function setProductStock(uint256 _id, uint256 _stock) onlyOwner onlyAdmin public {
    products[_id].stock = _stock;
  }
  
  function setProductTokenAddressAndPrice(uint256 _id, address _tokenAddress, uint256 _tokenPrice) onlyOwner onlyAdmin public {
    products[_id].tokenAddress = _tokenAddress;
    products[_id].priceInTokens = _tokenPrice;
  }

  // Only Owner or Admin can remove product
  function removeProduct(uint256 _id) onlyOwner onlyAdmin public returns (bool) {
    require(_id > 0);
    require(products[_id].priceInEth != 0);

    setProductPrice(_id, 0);
    setProductStock(_id, 0);
    setProductTokenAddressAndPrice(_id, 0, 0);
    
    ProductRemoved(_id);
    return true;
  }

  // Only Owner or Admin can set token and its price
  function setTokenPriceOfProduct(uint256 _id, address _tokenAddress, uint256 _priceInTokens) onlyOwner onlyAdmin public returns (bool) {
      require(_id > 0);
      require(_priceInTokens > 0);
      require(_tokenAddress != address(0));

      setProductTokenAddressAndPrice(_id, _tokenAddress, _priceInTokens);
      
      ProductTokenPriceSet(_tokenAddress, _priceInTokens, _id);
      return true;
  }

  // Everyone can get the information for the product
  function getProductInfo(uint256 id) view public returns (uint256, uint256, address, uint256) {
      Product storage product = products[id];
      return (product.priceInEth, product.stock, product.tokenAddress, product.priceInTokens);
  }

  // Only Owner can Withdraw from the contract
  function withdraw(uint256 _amount) onlyOwner public returns (bool) {
    require(_amount < this.balance);
    require(_amount > 0);
    
    msg.sender.transfer(_amount);
    
    Withdrawal(_amount);
    return true;
  }
  
  // Only Owner can Pay to someone from the contract
  function pay(address _to, uint256 _amount) onlyOwner public returns (bool) {
    require(_amount < this.balance);
    require(_amount > 0);

    _to.transfer(_amount);

    Payment(_to, _amount);
    return true;
  }  
}