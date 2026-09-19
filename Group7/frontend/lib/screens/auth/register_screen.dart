import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../customer/customer_dashboard_screen.dart';
import '../restaurant/restaurant_dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _restaurantNameController = TextEditingController();
  final _cuisineController = TextEditingController();

  String _selectedRole = 'customer'; // 'customer' or 'restaurant'
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _restaurantNameController.dispose();
    _cuisineController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await AuthService.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        role: _selectedRole,
        phone: _phoneController.text,
        address: _addressController.text,
        restaurantName: _selectedRole == 'restaurant' ? _restaurantNameController.text : null,
        cuisineType: _selectedRole == 'restaurant' ? _cuisineController.text : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created for ${user.name}!'),
            backgroundColor: Colors.green,
          ),
        );

        Widget destination = _selectedRole == 'restaurant'
            ? RestaurantDashboardScreen(user: user)
            : CustomerDashboardScreen(user: user);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => destination),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Account'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Register As',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Role Selector (Customer / Restaurant)
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Customer'),
                        value: 'customer',
                        groupValue: _selectedRole,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) => setState(() => _selectedRole = val!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Restaurant'),
                        value: 'restaurant',
                        groupValue: _selectedRole,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) => setState(() => _selectedRole = val!),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                CustomTextField(
                  controller: _nameController,
                  label: _selectedRole == 'restaurant' ? 'Owner Full Name' : 'Full Name',
                  prefixIcon: Icons.person_outline,
                  validator: (v) => (v == null || v.isEmpty) ? 'Please enter your name' : null,
                ),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                ),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) => (v == null || v.length < 4) ? 'Password must be at least 4 chars' : null,
                ),
                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                CustomTextField(
                  controller: _addressController,
                  label: _selectedRole == 'restaurant' ? 'Restaurant Address' : 'Delivery Address',
                  prefixIcon: Icons.location_on_outlined,
                  maxLines: 2,
                ),

                // Conditional fields for Restaurant
                if (_selectedRole == 'restaurant') ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Restaurant Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _restaurantNameController,
                    label: 'Restaurant Name',
                    prefixIcon: Icons.storefront,
                    validator: (v) => (v == null || v.isEmpty) ? 'Enter restaurant name' : null,
                  ),
                  CustomTextField(
                    controller: _cuisineController,
                    label: 'Cuisine Type (e.g. Italian, North Indian)',
                    prefixIcon: Icons.restaurant,
                  ),
                ],

                const SizedBox(height: 24),
                CustomButton(
                  text: 'Register Account',
                  isLoading: _isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
