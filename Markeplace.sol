// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Marketplace {
    address public owner;

    struct Shop {
        mapping(uint256 => Item) items;
        bool exists;
    }

    struct Item {
        uint256 price;
        bool listed;
    }

    mapping(address => Shop) public shops;

    event ShopCreated(address indexed shopOwner);
    event ItemAdded(address indexed shopOwner, uint256 indexed itemId, uint256 price);
    event ItemUnlisted(address indexed shopOwner, uint256 indexed itemId);
    event ItemPurchased(address indexed buyer, address indexed shopOwner, uint256 indexed itemId, uint256 quantity, uint256 totalPrice);

    modifier onlyShopOwner() {
        require(msg.sender == owner || shops[msg.sender].exists, "You are not a shop owner.");
        _;
    }

    modifier itemExists(address shopOwner, uint256 itemId) {
        require(shops[shopOwner].items[itemId].price > 0, "Item does not exist.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createShop() external {
        require(!shops[msg.sender].exists, "Shop already exists.");
        shops[msg.sender].exists = true;
        emit ShopCreated(msg.sender);
    }

    function addItem(uint256 itemId, uint256 price) external onlyShopOwner {
        require(shops[msg.sender].items[itemId].price == 0, "Item already exists.");
        shops[msg.sender].items[itemId] = Item(price, true);
        emit ItemAdded(msg.sender, itemId, price);
    }

    function unlistItem(uint256 itemId) external onlyShopOwner itemExists(msg.sender, itemId) {
        shops[msg.sender].items[itemId].listed = false;
        emit ItemUnlisted(msg.sender, itemId);
    }

    function purchaseItem(address shopOwner, uint256 itemId, uint256 quantity, address recipient, uint256 paymentCoin) external payable itemExists(shopOwner, itemId) {
        require(shops[shopOwner].items[itemId].listed, "Item is not listed.");
        uint256 totalPrice = shops[shopOwner].items[itemId].price * quantity;
        require(msg.value == totalPrice, "Incorrect payment amount.");

        // Handle payment logic and transfer funds to the shop owner
        // For simplicity, we'll just send the funds to the shop owner in this example
        payable(shopOwner).transfer(msg.value);

        emit ItemPurchased(msg.sender, shopOwner, itemId, quantity, totalPrice);
    }
}
