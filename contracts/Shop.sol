pragma solidity ^0.4.16;

import "./Owned.sol";
import "./IShop.sol";
import "./Order.sol";

contract Shop is Owned, IShop {

  struct Product {
    uint256 stock;
    uint256 priceInWei;
    mapping(address => uint256) priceInTokens;
  }

  mapping(address => bool) admins;
  //mapping (uint256 => Product) public products;
  Product[] products;

  modifier onlyAdmin {
    require(admins[msg.sender]);
    _;
  }

  modifier onlyOwnerAndAdmin {
    require(msg.sender == owner || admins[msg.sender]);
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
  function addProduct(uint256 _price, uint256 _stock) onlyOwnerAndAdmin public returns (bool) {
    require(_price > 0);
    require(_stock > 0);
    uint256 id = products.length++;

    Product storage p = products[id];
    p.priceInWei = _price;
    p.stock = _stock;

    ProductAdded(id, _price, _stock);
    return true;
  }
  
  function setProductPrice(uint256 _id, uint256 _price) onlyOwnerAndAdmin public {
    products[_id].priceInWei = _price;
  }

  function setProductStock(uint256 _id, uint256 _stock) onlyOwnerAndAdmin public {
    products[_id].stock = _stock;
  }
  
  function setProductTokenAddressAndPrice(uint256 _id, address _tokenAddress, uint256 _tokenPrice) onlyOwnerAndAdmin public {
    products[_id].priceInTokens[_tokenAddress] = _tokenPrice;
  }

  // Only Owner or Admin can remove product
  function removeProduct(uint256 _id) onlyOwnerAndAdmin public returns (bool) {
    require(_id > 0);
    require(products[_id].priceInWei != 0);
		
		for(uint256 j = _id; j < products.length-1; j++) {
			products[j] = products[j + 1];
		}
    
		products.length--;
    
    ProductRemoved(_id);
    return true;
  }

  // Only Owner or Admin can set token and its price
  function setTokenPriceOfProduct(uint256 _id, address _tokenAddress, uint256 _priceInTokens) onlyOwnerAndAdmin public returns (bool) {
      require(_id > 0);
      require(_priceInTokens > 0);
      require(_tokenAddress != address(0));

      setProductTokenAddressAndPrice(_id, _tokenAddress, _priceInTokens);
      
      ProductTokenPriceSet(_tokenAddress, _priceInTokens, _id);
      return true;
  }

  // Everyone can get the information for the product
  function getProductInfo(uint256 id) view public returns (uint256, uint256) {
      Product storage product = products[id];
      return (product.priceInWei, product.stock);
  }

  function getProductTokenPrice(uint256 id, address tokenAddress) view public returns (uint256 tokenPrice) {
    Product storage product = products[id];
    tokenPrice = product.priceInTokens[tokenAddress];
    return tokenPrice; 
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