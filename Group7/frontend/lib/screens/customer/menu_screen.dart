import 'package:flutter/material.dart';
import '../../models/food_item_model.dart';
import '../../models/restaurant_model.dart';
import '../../services/api_service.dart';
import '../../services/cart_service.dart';
import '../../config/api_constants.dart';
import 'cart_screen.dart';

class MenuScreen extends StatefulWidget {
  final RestaurantModel restaurant;

  const MenuScreen({super.key, required this.restaurant});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<FoodItemModel> _foodItems = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _fetchMenuItems();
  }

  Future<void> _fetchMenuItems() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get('${ApiConstants.foodItems}/restaurant/${widget.restaurant.id}');
      if (res['data'] != null && mounted) {
        final list = (res['data'] as List).map((i) => FoodItemModel.fromJson(i)).toList();
        setState(() {
          _foodItems = list;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load menu: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartService.instance;

    // Extract unique categories
    final categories = ['All', ..._foodItems.map((e) => e.category).toSet()];

    // Filter items
    final filteredItems = _selectedCategory == 'All'
        ? _foodItems
        : _foodItems.where((i) => i.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant.name),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Restaurant Summary Header
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.restaurant.imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.restaurant, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.restaurant.name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.restaurant.cuisineType,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.restaurant.address,
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Category Filter Chips
                if (categories.length > 1)
                  Container(
                    height: 48,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        final cat = categories[idx];
                        final isSelected = cat == _selectedCategory;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedCategory = cat),
                        );
                      },
                    ),
                  ),

                // Food Items List
                Expanded(
                  child: filteredItems.isEmpty
                      ? const Center(child: Text('No food items available.'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredItems.length,
                          separatorBuilder: (_, __) => const Divider(height: 20),
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Veg / Non-Veg Tag
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: item.isVeg ? Colors.green : Colors.red,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.circle,
                                    size: 10,
                                    color: item.isVeg ? Colors.green : Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Food Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '₹${item.price.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (item.description.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          item.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Add Button or Out of Stock Tag
                                if (!item.isAvailable)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Out of Stock',
                                      style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  )
                                else
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Theme.of(context).primaryColor,
                                      side: BorderSide(color: Theme.of(context).primaryColor),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () {
                                      cart.addItem(item, widget.restaurant.id, widget.restaurant.name);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Added ${item.name} to cart!'),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                    child: const Text('ADD', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
      // Floating Cart Bar
      bottomNavigationBar: ListenableBuilder(
        listenable: cart,
        builder: (context, _) {
          if (cart.items.isEmpty) return const SizedBox.shrink();
          return Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${cart.totalItemCount} ITEMS | ₹${cart.subtotal.toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const Text(
                        'Extra delivery charges may apply',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.shopping_cart, size: 18),
                    label: const Text('View Cart', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
