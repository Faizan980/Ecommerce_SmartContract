// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Ecommerce {
    struct Product { // stores all the information product metadata in the struct data type;
        string title;
        string desc;
        address payable seller;
        uint productid;
        uint price;
        address buyer;
        bool delivered;
    }
    event registered(string _title, uint productid, address seller);
    event bought(uint productid, address buyer);
    event delivered(uint productid);
    uint counter = 1;
    Product[] public product; // create dynamic array to store information of multiple product.

    function registerProduct(string memory _title, string memory _desc, uint _price) public { // We need these information to registerProduct
        require (_price>0, "Price should be greater then zero"); // check the price must be greater than zero
        Product memory tempProduct; // store information of array in tempProduct
        tempProduct.title = _title;
        tempProduct.desc = _desc;
        tempProduct.price = _price * 10 ** 18;
        tempProduct.seller = payable(msg.sender); // price must be stored in msg.sender address
        tempProduct.productid = counter; 
        product.push(tempProduct);
        counter++; // add counter productid information with the increment of one if one Product is added into the array following the index value.

        emit registered(_title, tempProduct.productid, msg.sender);
    }

    function buy(uint _productid) public payable {
        require(product[_productid-1].price == msg.value, "Please pay the exact price");
        require(product[_productid-1].seller != msg.sender, "Seller can not be buyer");
        product[_productid-1].buyer = msg.sender;

        emit bought(_productid, msg.sender);
    }

    function delivery(uint _productid) public {
        require(product[_productid-1].buyer==msg.sender, "Only buyer can confirm it");
        product[_productid-1].delivered = true;
        product[_productid-1].seller.transfer(product[_productid-1].price);

        emit delivered(_productid);
    }
}