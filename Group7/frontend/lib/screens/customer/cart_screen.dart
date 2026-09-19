import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/cart_service.dart';
import '../../config/api_constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import 'order_details_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _addressController = TextEditingController();
  bool _isLoading = false;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService.getSavedUser();
    if (user != null && mounted) {
      setState(() {
        _currentUser = user;
        _addressController.text = user.address.isNotEmpty ? user.address : 'Default Street Address';
      });
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final cart = CartService.instance;
    if (cart.items.isEmpty) return;

    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid delivery address'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final payload = {
        'restaurantId': cart.restaurantId,
        'deliveryAddress': _addressController.text.trim(),
        'paymentType': 'Cash On Delivery',
        'items': cart.items.map((item) => item.toOrderPayload()).toList(),
      };

      final response = await ApiService.post(ApiConstants.orders, payload);

      if (response['success'] == true && mounted) {
        final newOrder = OrderModel.fromJson(response['data']);
        cart.clearCart();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully! 🎉'), backgroundColor: Colors.green),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailsScreen(initialOrder: newOrder),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartService.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear Cart',
              onPressed: () {
                cart.clearCart();
                setState(() {});
              },
            ),
        ],
      ),
      body: ListenableBuilder(
        listenable: cart,
        builder: (context, _) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Browse delicious food and add items to your cart!',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          final deliveryFee = 30.0;
          final totalBill = cart.subtotal + deliveryFee;

          return Column(
            children: [
              // Restaurant Name Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Colors.orange.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.storefront, size: 18, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ordering from: ${cart.restaurantName ?? 'Restaurant'}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                      ),
                    ),
                  ],
                ),
              ),

              // Items List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const Divider(height: 16),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Row(
                      children: [
                        // Veg / Non-Veg Icon
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: item.foodItem.isVeg ? Colors.green : Colors.red,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.circle,
                            size: 10,
                            color: item.foodItem.isVeg ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Item details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.foodItem.name,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                              ),
                              Text(
                                '₹${item.foodItem.price.toStringAsFixed(0)} each',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                            ],
                          ),
                        ),

                        // Quantity Stepper
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 16),
                                onPressed: () => cart.decreaseQuantity(item.foodItem.id),
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                padding: EdgeInsets.zero,
                              ),
                              Text(
                                '${item.quantity}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 16),
                                onPressed: () => cart.increaseQuantity(item.foodItem.id),
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Total item price
                        Text(
                          '₹${item.totalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Bottom Checkout Panel
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, -2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Delivery Address Field
                      CustomTextField(
                        controller: _addressController,
                        label: 'Delivery Address',
                        prefixIcon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 8),

                      // Bill Details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Items Subtotal', style: TextStyle(color: Colors.grey.shade700)),
                          Text('₹${cart.subtotal.toStringAsFixed(0)}'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Delivery Charges', style: TextStyle(color: Colors.grey.shade700)),
                          Text('₹${deliveryFee.toStringAsFixed(0)}'),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Grand Total',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '₹${totalBill.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Checkout Button
                      CustomButton(
                        text: 'Place Order (Cash on Delivery)',
                        icon: Icons.check_circle_outline,
                        isLoading: _isLoading,
                        onPressed: _placeOrder,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
