import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  // Login
  static Future<UserModel> login(String email, String password) async {
    final response = await ApiService.post(ApiConstants.login, {
      'email': email.trim(),
      'password': password.trim(),
    });

    final token = response['token'];
    final userData = response['user'];

    final user = UserModel.fromJson(userData);

    // Save session
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_data', jsonEncode(user.toJson()));

    return user;
  }

  // Register
  static Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String role = 'customer',
    String phone = '',
    String address = '',
    String? restaurantName,
    String? cuisineType,
  }) async {
    final payload = {
      'name': name.trim(),
      'email': email.trim(),
      'password': password.trim(),
      'role': role,
      'phone': phone.trim(),
      'address': address.trim(),
    };

    if (role == 'restaurant' && restaurantName != null) {
      payload['restaurantName'] = restaurantName.trim();
      payload['cuisineType'] = cuisineType?.trim() ?? 'Multi-Cuisine';
    }

    final response = await ApiService.post(ApiConstants.register, payload);

    final token = response['token'];
    final userData = response['user'];

    final user = UserModel.fromJson(userData);

    // Save session
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_data', jsonEncode(user.toJson()));

    return user;
  }

  // Get currently saved user from local storage
  static Future<UserModel?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Check if logged in
  static Future<bool> isLoggedIn() async {
    final token = await ApiService.getToken();
    return token != null && token.isNotEmpty;
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }
}
