import 'package:admin_app/models/dashboard_btn_model.dart';
import 'package:admin_app/providers/theme_provider.dart';
import 'package:admin_app/services/assets_manager.dart';
import 'package:admin_app/widgets/app_name.dart';
import 'package:admin_app/widgets/dashboard_btn.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const AppNameText(text: "Dashboard"),
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Image(
            image: AssetImage(AssetsManager.shoppingCart),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              themeProvider.setDarkTheme(
                  themeValue: !themeProvider.getIsDarkTheme);
            },
            icon: Icon(themeProvider.getIsDarkTheme
                ? Icons.light_mode
                : Icons.dark_mode),
            // color: Colors.red,
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: List.generate(
          3,
          (index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: DashboardButtonWidget(
                title: DashboardButtonModel.dashboardButtonList(context)[index]
                    .title,
                imagePath:
                    DashboardButtonModel.dashboardButtonList(context)[index]
                        .imagePath,
                onPressed:
                    DashboardButtonModel.dashboardButtonList(context)[index]
                        .onPressed,
              ),
            );
          },
        ),
      ),
    );
  }
}
