pragma solidity ^0.4.16;

contract Owned {
  address public owner;

  function Owned() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function getOwner() view public returns (address) {
    return owner;
  }
}