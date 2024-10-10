import 'package:flutter/material.dart';

class AppConstants {
  static const String productImageUrl =
      "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cHJvZHVjdHxlbnwwfHwwfHx8MA%3D%3D";

  static List<String> categoriesList = [
    "Phones",
    "Cosmetics",
    "Shoes",
    "Watches",
    "Laptops",
    "Books",
    "Electronics",
    "Accessories",
  ];
  static List<DropdownMenuItem<String>>? get categoriesDropdownList {
    List<DropdownMenuItem<String>>? menuItems =
        List<DropdownMenuItem<String>>.generate(
      categoriesList.length,
      (index) {
        return DropdownMenuItem(
          value: categoriesList[index],
          child: Text(
            categoriesList[index],
          ),
        );
      },
    );
    return menuItems;
  }
}
