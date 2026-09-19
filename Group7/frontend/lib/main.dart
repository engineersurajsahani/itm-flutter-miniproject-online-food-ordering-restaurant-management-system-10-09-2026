import 'package:flutter/material.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/customer/customer_dashboard_screen.dart';
import 'screens/restaurant/restaurant_dashboard_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedUser = await AuthService.getSavedUser();
  runApp(FoodOrderingApp(initialUser: savedUser));
}

class FoodOrderingApp extends StatelessWidget {
  final UserModel? initialUser;

  const FoodOrderingApp({super.key, this.initialUser});

  Widget _getInitialScreen() {
    if (initialUser != null) {
      if (initialUser!.role == 'admin') {
        return const AdminDashboardScreen();
      } else if (initialUser!.role == 'restaurant') {
        return RestaurantDashboardScreen(user: initialUser!);
      } else {
        return CustomerDashboardScreen(user: initialUser!);
      }
    }
    return const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodHub Online Food Ordering',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.deepOrange,
        primaryColor: const Color(0xFFFF5722),
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFF5722),
          foregroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 1.5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: _getInitialScreen(),
    );
  }
}
