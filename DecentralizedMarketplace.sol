// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract DecentralizedMarketplace {
    address public owner;
    
    struct Item {
        string name;
        string description;
        uint256 price;
        uint256 quantity;
        address seller;
    }
    
    mapping(uint256 => Item) public items;
    uint256 public itemCount;
    
    event ItemListed(uint256 itemId, string name, uint256 price, uint256 quantity, address seller);
    event ItemUpdated(uint256 itemId, string name, uint256 price, uint256 quantity);
    event ItemDeleted(uint256 itemId);
    event ItemPurchased(uint256 itemId, address buyer, uint256 quantity);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    function listNewItem(string memory _name, string memory _description, uint256 _price, uint256 _quantity) public {
        require(bytes(_name).length > 0, "Item name cannot be empty");
        require(_price > 0, "Price must be greater than zero");
        require(_quantity > 0, "Quantity must be greater than zero");
        
        itemCount++;
        items[itemCount] = Item(_name, _description, _price, _quantity, msg.sender);
        emit ItemListed(itemCount, _name, _price, _quantity, msg.sender);
    }
    
    function updateItem(uint256 _itemId, string memory _name, uint256 _price, uint256 _quantity) public {
        require(_itemId <= itemCount && _itemId > 0, "Invalid item ID");
        Item storage item = items[_itemId];
        require(item.seller == msg.sender, "Only the seller can update the item");
        
        item.name = _name;
        item.price = _price;
        item.quantity = _quantity;
        
        emit ItemUpdated(_itemId, _name, _price, _quantity);
    }
    
    function deleteItem(uint256 _itemId) public {
    require(_itemId <= itemCount && _itemId > 0, "Invalid item ID");
    Item storage item = items[_itemId];
    require(item.seller == msg.sender, "Only the seller can delete the item");

    // İlgili ürünü sil
    delete items[_itemId];

    // Ürün sayısını güncelle
    itemCount--;

    // Etkinlik bildirimi
    emit ItemDeleted(_itemId);
}

    

    function purchaseItem(uint256 _itemId, uint256 _quantity) public payable {
    require(_itemId <= itemCount && _itemId > 0, "Invalid item ID");
    Item storage item = items[_itemId];
    require(item.quantity >= _quantity, "Not enough quantity available");
    require(msg.value == item.price * _quantity, "Incorrect payment amount");


    // Kontroller başarılı, işlemi gerçekleştir
    item.quantity -= _quantity;
    payable(item.seller).transfer(msg.value);

    // Etkinlik bildirimi
    emit ItemPurchased(_itemId, msg.sender, _quantity);
    }
    

    function withdrawBalance() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}