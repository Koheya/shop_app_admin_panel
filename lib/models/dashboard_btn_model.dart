// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:admin_app/screens/orders/order_screen.dart';
import 'package:admin_app/screens/search_screen.dart';
import 'package:admin_app/screens/upload_and_edit_product.dart';
import 'package:admin_app/services/assets_manager.dart';
import 'package:flutter/material.dart';

class DashboardButtonModel {
  final String title, imagePath;
  final Function onPressed;
  DashboardButtonModel({
    required this.title,
    required this.imagePath,
    required this.onPressed,
  });

  static List<DashboardButtonModel> dashboardButtonList(BuildContext context) =>
      [
        DashboardButtonModel(
          title: "Add a new product",
          imagePath: AssetsManager.cloud,
          onPressed: () {
            Navigator.pushNamed(context, UploadNewProduct.routeName);
          },
        ),
        DashboardButtonModel(
          title: "Inspect all products",
          imagePath: AssetsManager.shoppingCart,
          onPressed: () {
            Navigator.pushNamed(context, SearchScreen.routeName);
          },
        ),
        DashboardButtonModel(
          title: "View all orders",
          imagePath: AssetsManager.order,
          onPressed: () {
            Navigator.pushNamed(context, OrderScreen.routeName);
          },
        ),
      ];
}
