import 'package:admin_app/constants/theme_data.dart';
import 'package:admin_app/firebase_options.dart';
import 'package:admin_app/providers/orders_provider.dart';
import 'package:admin_app/providers/product_provider.dart';
import 'package:admin_app/providers/theme_provider.dart';
import 'package:admin_app/screens/dashboard_screen.dart';
import 'package:admin_app/screens/orders/order_screen.dart';
import 'package:admin_app/screens/search_screen.dart';
import 'package:admin_app/screens/upload_and_edit_product.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: SelectableText(
                    "An error has been occured ${snapshot.error}"),
              ),
            );
          }
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) {
                  return ThemeProvider();
                },
              ),
              ChangeNotifierProvider(
                create: (_) {
                  return ProductProvider();
                },
              ),
              ChangeNotifierProvider(
                create: (_) {
                  return OrdersProvider();
                },
              ),
            ],
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: Styles.themeData(
                      context: context,
                      isDarkMode: themeProvider.getIsDarkTheme),
                  title: "Admin AR",
                  home: const DashboardScreen(),
                  routes: {
                    OrderScreen.routeName: (context) => const OrderScreen(),
                    SearchScreen.routeName: (context) => const SearchScreen(),
                    UploadNewProduct.routeName: (context) =>
                        const UploadNewProduct(),
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
